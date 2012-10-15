-------------------------------------------------------------------------------
--                                                                           --
--                                  Yolk                                     --
--                                                                           --
--                                Yolk.Server                                --
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
with AWS.MIME;
with AWS.Net.WebSocket.Registry.Control;
with AWS.Server.Log;
with AWS.Session;
with Yolk.Configuration;
with Yolk.Log;
with Yolk.Static_Content;

package body Yolk.Server is

   type State_Type is (Not_Initialized, Initialized, Started, Stopped);

   protected State_Manager is
      procedure Set
        (Current_State :    out State_Type;
         New_State     : in     State_Type);
   private
      State : State_Type := Not_Initialized;
   end State_Manager;
   --  This makes sure that Create can only ever be called once.

   ---------------------
   --  State_Manager  --
   ---------------------

   protected body State_Manager is
      procedure Set
        (Current_State :    out State_Type;
         New_State     : in     State_Type)
      is
      begin
         Current_State := State;
         State := New_State;
      end Set;
   end State_Manager;

   --------------
   --  Create  --
   --------------

   function Create
     (Compress_Static_Content : in Boolean := True;
      Load_Extra_MIME_Types   : in Boolean := True;
      Server_Uses_WebSockets  : in Boolean := True;
      Set_Dispatchers         : in Resource_Dispatchers;
      Unexpected              : in AWS.Exceptions.Unexpected_Exception_Handler)
      return HTTP
   is
      use Yolk.Configuration;

      State : State_Type;
   begin
      return WS : HTTP do
         State_Manager.Set (Current_State => State,
                            New_State     => Initialized);

         if State = Not_Initialized then
            WS.Load_MIME_Types := Load_Extra_MIME_Types;

            WS.Uses_Compressed_Cache := Compress_Static_Content;

            WS.Web_Server_Config := Get_AWS_Configuration;

            WS.Uses_WebSockets := Server_Uses_WebSockets;

            Set_Dispatchers (WS.URI_Handlers);

            WS.Handle_The_Unexpected := Unexpected;
         end if;
      end return;
   end Create;

   -------------
   --  Start  --
   -------------

   procedure Start
     (WS : in out HTTP)
   is
      use Ada.Directories;
      use Yolk.Configuration;
      use Yolk.Log;
      use Yolk.Static_Content;

      State : State_Type;
   begin
      State_Manager.Set (Current_State => State,
                         New_State     => Started);

      if State = Initialized or State = Stopped then
         if WS.Uses_Compressed_Cache then
            Static_Content_Cache_Setup;
         end if;

         if WS.Load_MIME_Types then
            AWS.MIME.Load (MIME_File => Config.Get (MIME_Types));
            --  Load the MIME type file. We need to do this here, because
            --  the AWS.MIME package has already been initialized with the
            --  default AWS configuration parameters, and in these the
            --  aws.mime file is placed in ./ whereas our aws.mime is in
            --  Configuration.MIME_Types.
         end if;

         AWS.Server.Set_Unexpected_Exception_Handler
           (Web_Server => WS.Web_Server,
            Handler    => WS.Handle_The_Unexpected);

         if AWS.Config.Session (WS.Web_Server_Config)
           and then Exists (Config.Get (Session_Data_File))
         then
            AWS.Session.Load (Config.Get (Session_Data_File));
            --  If sessions are enabled and the Session_Data_File exists,
            --  then load the old session data.
         end if;

         AWS.Server.Start (Web_Server => WS.Web_Server,
                           Dispatcher => WS.URI_Handlers,
                           Config     => WS.Web_Server_Config);

         if WS.Uses_WebSockets then
            AWS.Net.WebSocket.Registry.Control.Start;
            --  Start listening for incoming WebSocket messages.
         end if;

         if Config.Get (AWS_Access_Log_Activate) then
            AWS.Server.Log.Start
              (Web_Server => WS.Web_Server,
               Callback   => Yolk.Log.AWS_Access_Log_Writer'Access,
               Name       => "AWS Access Log");
         end if;

         if Config.Get (AWS_Error_Log_Activate) then
            AWS.Server.Log.Start_Error
              (Web_Server => WS.Web_Server,
               Callback   => Yolk.Log.AWS_Error_Log_Writer'Access,
               Name       => "AWS Error Log");
            --  Start the access and error logs.
         end if;

         Trace (Info,
                "Server "
                & AWS.Config.Server_Name (WS.Web_Server_Config)
                & " listening on port"
                & AWS.Config.Server_Port (WS.Web_Server_Config)'Img
                & ". Yolk version "
                & Yolk.Version);
      end if;
   end Start;

   ------------
   --  Stop  --
   ------------

   procedure Stop
     (WS : in out HTTP)
   is
      use Yolk.Configuration;
      use Yolk.Log;

      State : State_Type;
   begin
      State_Manager.Set (Current_State => State,
                         New_State     => Stopped);

      if State = Started then
         if AWS.Config.Session (WS.Web_Server_Config) then
            AWS.Session.Save (Config.Get (Session_Data_File));
            --  If sessions are enabled, then save the session data to the
            --  Session_Data_File.
         end if;

         if WS.Uses_WebSockets then
            AWS.Net.WebSocket.Registry.Control.Shutdown;
            --  Stop listening for incoming WebSocket messages.
         end if;

         AWS.Server.Shutdown (WS.Web_Server);

         if AWS.Server.Log.Is_Active (WS.Web_Server) then
            AWS.Server.Log.Stop (WS.Web_Server);
         end if;

         if AWS.Server.Log.Is_Error_Active (WS.Web_Server) then
            AWS.Server.Log.Stop_Error (WS.Web_Server);
         end if;

         Trace (Info,
                "Stopped " & AWS.Config.Server_Name (WS.Web_Server_Config));
      end if;
   end Stop;

end Yolk.Server;
