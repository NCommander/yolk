-------------------------------------------------------------------------------
--                                                                           --
--                                  Yolk                                     --
--                                                                           --
--                     Copyright (C) 2010, Thomas L�cke                      --
--                                                                           --
--  Yolk is free software;  you can  redistribute it  and/or modify it under --
--  terms of the  GNU General Public License as published  by the Free Soft- --
--  ware  Foundation;  either version 2,  or (at your option) any later ver- --
--  sion.  Yolk is distributed in the hope that it will be useful, but WITH- --
--  OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
--  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
--  for  more details.  You should have  received  a copy of the GNU General --
--  Public License  distributed with Yolk.  If not, write  to  the  Free     --
--  Software Foundation,  51  Franklin  Street,  Fifth  Floor, Boston,       --
--  MA 02110 - 1301, USA.                                                    --
--                                                                           --
-------------------------------------------------------------------------------

with Ada.Directories;
with Ada.Exceptions;
with AWS.Config;
with AWS.Server;
with AWS.Server.Log;
with AWS.Services.Dispatchers.URI;
with AWS.Session;
with Configuration;
with Handlers;
with Logfile_Cleanup;
with Process_Control;
with Rotating_Log;

procedure Yolk
is

   use Ada.Exceptions;
   use Configuration;
   use Rotating_Log;

   Logfile_Monitor_Stop : exception;
   --  Is raised when Logfile_Monitor.Stop is called.

   Resource_Handlers : AWS.Services.Dispatchers.URI.Handler;
   --  The various resource handlers. These are defined in the Handlers and
   --  My_Handlers packages.

   Sessions          : constant String := Config.Get (Session_Data_File);
   --  Path to the sessions data file.

   Web_Server        : AWS.Server.HTTP;
   --  The main webserver object.

   Web_Server_Config : constant AWS.Config.Object := AWS.Config.Get_Current;
   --  Set the AWS config object. First look for a file called aws.ini in the
   --  current directory, and if found, then override the default configuration
   --  with the values found herein.
   --  Second look for a file called <program name>.ini in the current
   --  directory, and if found, override whatever configuration settings found
   --  herein.
   --  Neither of these files are necessary, if the default AWS configuration
   --  is sufficient for this application.
   --  See the AWS manual for more information on the possible configuration
   --  settings.

   procedure Start_Server (Session_Data_File : in String);
   --  Start the AWS server. A short message is written to the Info trace
   --  whenever the server is started.

   procedure Stop_Server (Session_Data_File : in String);
   --  Stop the AWS server. A short message is written to the Info trace
   --  whenever the server is stopped.

   task Logfile_Monitor is
      entry Start;
      entry Stop;
   end Logfile_Monitor;
   --  This task monitor the aws.ini Log_File_Directory and deletes excess
   --  logfiles. The amount of logfiles kept are defined by the
   --  Logfile_Cleanup.Amount_Of_Files_To_Keep constant.

   --------------------
   --  Start_Server  --
   --------------------

   procedure Start_Server (Session_Data_File : in String)
   is

      use Ada.Directories;

   begin

      if AWS.Config.Session (Web_Server_Config)
        and then Exists (Session_Data_File)
      then
         AWS.Session.Load (Session_Data_File);
      end if;
      --  Load the old sessions data, if sessions are enabled and the
      --  Session_Data_File exists.

      AWS.Server.Log.Start (Web_Server => Web_Server,
                            Auto_Flush => False);
      --  Start the access log.
      --  Set Auto_Flush to True if you want access data to be written to file
      --  instantly. Doing to incurs a performance hit if the server is very
      --  busy.

      AWS.Server.Log.Start_Error (Web_Server);

      AWS.Server.Start (Web_Server => Web_Server,
                        Dispatcher => Resource_Handlers,
                        Config     => Web_Server_Config);

      Track (Handle     => Info,
             Log_String => "Started " &
             AWS.Config.Server_Name (Web_Server_Config));

   end Start_Server;

   -------------------
   --  Stop_Server  --
   -------------------

   procedure Stop_Server (Session_Data_File : in String)
   is
   begin

      if AWS.Config.Session (Web_Server_Config) then
         AWS.Session.Save (Session_Data_File);
      end if;
      --  Save the sessions data to the Session_Data_File, if sessions are
      --  enabled.

      AWS.Server.Shutdown (Web_Server);

      AWS.Server.Log.Stop (Web_Server);

      AWS.Server.Log.Stop_Error (Web_Server);

      Track (Handle     => Info,
             Log_String => "Stopped " &
             AWS.Config.Server_Name (Web_Server_Config));

   end Stop_Server;

   ---------------------
   -- Logfile_Monitor --
   ---------------------

   task body Logfile_Monitor
   is

      use AWS.Config;
      use Logfile_Cleanup;

      Interval    : constant Duration := 60.0;
      --  How often do we check for excess/old logfiles?

      Good_To_Go  : Boolean := False;

   begin

      loop
         select
            accept Start do
               Good_To_Go := True;

               Track (Handle     => Info,
                      Log_String => "Logfile monitor started.");
            end Start;
         or
            accept Stop do
               raise Logfile_Monitor_Stop;
            end Stop;
         or
            delay Interval;
            if Good_To_Go then
               Clean_Up (Config_Object => Web_Server_Config,
                         Web_Server    => Web_Server);
            else
               Track (Handle     => Error,
                      Log_String => "Logfile_Monitor.Start not called.");
            end if;
         end select;
      end loop;

   end Logfile_Monitor;

begin

   Track (Handle     => Info,
          Log_String => "Starting " &
          AWS.Config.Server_Name (Web_Server_Config) &
          ". Listening on port" &
          AWS.Config.Server_Port (Web_Server_Config)'Img);
   --  We're alive! Log this fact to the Info track.

   Handlers.Set (RH => Resource_Handlers);
   --  Populate the Resource_Handlers object.

   Logfile_Monitor.Start;
   --  Start the logfile monitor.

   Start_Server (Sessions);
   --  Start the server.

   Process_Control.Wait;
   --  This is the main "loop". We will wait here as long as the
   --  Process_Control.Controller.Check entry barrier is False.

   Stop_Server (Sessions);
   --  Shutdown requested in Process_Control.Controller, so we will attempt to
   --  shutdown the server.

   Logfile_Monitor_Block :
   declare
   begin

      Logfile_Monitor.Stop;
      --  This call raises the Logfile_Monitor_Stop exception, which we then
      --  catch below. This is the only way I've been able to come up with that
      --  can handle closing down the Logfile_Monitor task cleanly.

   exception
      when Logfile_Monitor_Stop =>
         Track (Handle     => Info,
                Log_String => "Logfile monitor stopped.");

   end Logfile_Monitor_Block;

exception
   when Event : others =>
      Track (Handle     => Error,
             Log_String => Exception_Information (Event));
      Stop_Server (Sessions);
      Logfile_Monitor.Stop;
      --  If an exception is caught, write its contents to the Error trace,
      --  attempt to stop the server and the logfile monitor task.

end Yolk;
