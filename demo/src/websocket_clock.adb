-------------------------------------------------------------------------------
--                                                                           --
--                                  Yolk                                     --
--                                                                           --
--                            Websocket_Clock                                --
--                                                                           --
--                                  BODY                                     --
--                                                                           --
--                   Copyright (C) 2010-2012, Thomas Løcke                   --
--                                                                           --
--  This is free software;  you can redistribute it and/or modify it         --
--  under terms of the  GNU General Public License  as published by the      --
--  Free Software  Foundation;  either version 3,  or (at your  option) any  --
--  later version. This library is distributed in the hope that it will be   --
--  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of  --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     --
--  You should have received a copy of the GNU General Public License and    --
--  a copy of the GCC Runtime Library Exception along with this program;     --
--  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
--  <http://www.gnu.org/licenses/>.                                          --
--                                                                           --
-------------------------------------------------------------------------------

with Ada.Calendar;
with Ada.Calendar.Formatting;
with Ada.Text_IO;
with AWS.Net.WebSocket.Registry;
--  with AWS.Net.WebSocket.Registry.Control;
with Task_Controller;

package body Websocket_Clock is

   Created : Boolean := False;
   --  A boolean that will be set to True when a websocket has been created

   Rcp : constant AWS.Net.WebSocket.Registry.Recipient :=
           AWS.Net.WebSocket.Registry.Create (URI => "/websocket");
   --  Targets all clients (any Origin) whose URI is /websocket

   task Clocker;
   --  TODO: Write comment.

   task body Clocker
   is
      use Task_Controller;
   begin
      loop
         AWS.Net.WebSocket.Registry.Send
           (To      => Rcp,
            Message => Ada.Calendar.Formatting.Image
              (Ada.Calendar.Clock, True));

         delay 1.0;

         exit when Task_State = Down;
      end loop;
   end Clocker;

   type Object is new AWS.Net.WebSocket.Object with null record;

   overriding procedure On_Close
     (Socket  : in out Object;
      Message : in     String);
   --  Close event received from the server

   overriding procedure On_Message
     (Socket  : in out Object;
      Message : in     String);
   --  Message received from the server

   overriding procedure On_Open
     (Socket  : in out Object;
      Message : in     String);
   --  Open event received from the server

   --------------
   --  Create  --
   --------------

   function Create
     (Socket  : AWS.Net.Socket_Access;
      Request : AWS.Status.Data)
      return AWS.Net.WebSocket.Object'Class is
   begin
      Created := True;

      Ada.Text_IO.Put_Line ("Create");
      return Object'(AWS.Net.WebSocket.Object
                     (AWS.Net.WebSocket.Create (Socket, Request))
                     with null record);
   end Create;

   ----------------
   --  On_Close  --
   ----------------

   overriding procedure On_Close
     (Socket  : in out Object;
      Message : in     String)
   is
   begin
      Ada.Text_IO.Put_Line
        ("Received : Connection_Close "
         & AWS.Net.WebSocket.Error_Type'Image (Socket.Error) & ", " & Message);
   end On_Close;

   ------------------
   --  On_Message  --
   ------------------

   overriding procedure On_Message
     (Socket  : in out Object;
      Message : in     String)
   is
   begin
      Ada.Text_IO.Put_Line ("Received : " & Message);

      Socket.Send (Message => "Some message");

      for k in 1 .. 20 loop
         Socket.Send
           (Message => Ada.Calendar.Formatting.Image
              (Ada.Calendar.Clock, True));
         delay 1.0;
      end loop;
   end On_Message;

   ---------------
   --  On_Open  --
   ---------------

   overriding procedure On_Open
     (Socket  : in out Object;
      Message : in     String)
   is
      pragma Unreferenced (Socket);
   begin
      Ada.Text_IO.Put_Line ("On_Open: " & Message);
   end On_Open;

end Websocket_Clock;
