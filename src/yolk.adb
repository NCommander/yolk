-------------------------------------------------------------------------------
--                                                                           --
--                                  Yolk                                     --
--                                                                           --
--                                  BODY                                     --
--                                                                           --
--                   Copyright (C) 2010-2012, Thomas Løcke                   --
--                                                                           --
--  This library is free software;  you can redistribute it and/or modify    --
--  it under terms of the  GNU General Public License  as published by the   --
--  Free Software  Foundation;  either version 3,  or (at your  option) any  --
--  later version. This library is distributed in the hope that it will be   --
--  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of  --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     --
--                                                                           --
--  As a special exception under Section 7 of GPL version 3, you are         --
--  granted additional permissions described in the GCC Runtime Library      --
--  Exception, version 3.1, as published by the Free Software Foundation.    --
--                                                                           --
--  You should have received a copy of the GNU General Public License and    --
--  a copy of the GCC Runtime Library Exception along with this program;     --
--  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
--  <http://www.gnu.org/licenses/>.                                          --
--                                                                           --
-------------------------------------------------------------------------------

with Ada.Directories;
with AWS.Dispatchers.Callback;
with AWS.MIME;
with AWS.Net.WebSocket.Registry.Control;
with AWS.Server.Log;
with AWS.Session;
with Yolk.Configuration;
with Yolk.Handlers;
with Yolk.Log;
with Yolk.Not_Found;
with Yolk.Whoops;

package body Yolk is

   --------------
   --  Create  --
   --------------

   function Create
     (Load_Extra_MIME_Types    : in Boolean := True;
      Register_URI_Dispatchers : in Boolean := True)
     return Server
   is
      use Yolk.Configuration;
   begin
      return S : Server do
         S.Web_Server_Config := Get_AWS_Configuration;

         if Load_Extra_MIME_Types then
            AWS.MIME.Load (MIME_File => Config.Get (MIME_Types));
            --  Load the MIME type file. We need to do this here, because the
            --  AWS.MIME package has already been initialized with the default
            --  AWS configuration parameters, and in these the aws.mime file is
            --  placed in ./ whereas our aws.mime is in
            --  Configuration.MIME_Types.
         end if;

         if Register_URI_Dispatchers then
            Yolk.Handlers.Set (S.URI_Handlers);

            S.URI_Handlers.Register_Default_Callback
              (Action => AWS.Dispatchers.Callback.Create
                 (Callback => Yolk.Not_Found.Generate'Access));

            S.Got_Dispatchers := True;
         end if;

         AWS.Server.Set_Unexpected_Exception_Handler
           (Web_Server => S.Web_Server,
            Handler    => Yolk.Whoops.Unexpected_Exception_Handler'Access);
      end return;
   end Create;

   -------------
   --  Start  --
   -------------

   procedure Start
     (S                : in out Server;
      Start_WebSockets : in Boolean := True)
   is
      use Ada.Directories;
      use Yolk.Configuration;
      use Yolk.Log;
   begin
      if AWS.Config.Session (S.Web_Server_Config)
        and then Exists (Config.Get (Session_Data_File))
      then
         AWS.Session.Load (Config.Get (Session_Data_File));
         --  If sessions are enabled and the Session_Data_File exists, then
         --  load the old session data.
      end if;

      AWS.Server.Start (Web_Server => S.Web_Server,
                        Dispatcher => S.URI_Handlers,
                        Config     => S.Web_Server_Config);

      if Start_WebSockets  then
         AWS.Net.WebSocket.Registry.Control.Start;
         --  Start listening for incoming WebSocket messages.
      end if;

      if Config.Get (AWS_Access_Log_Activate) then
         AWS.Server.Log.Start
           (Web_Server => S.Web_Server,
            Callback   => Yolk.Log.AWS_Access_Log_Writer'Access,
            Name       => "AWS Access Log");
      end if;

      if Config.Get (AWS_Error_Log_Activate) then
         AWS.Server.Log.Start_Error
           (Web_Server => S.Web_Server,
            Callback   => Yolk.Log.AWS_Error_Log_Writer'Access,
            Name       => "AWS Error Log");
         --  Start the access and error logs.
      end if;

      Trace (Handle  => Info,
             Message => "Started " &
               AWS.Config.Server_Name (S.Web_Server_Config));
      Trace (Handle  => Info,
             Message => "Yolk version " & Yolk.Version);
   end Start;

end Yolk;
