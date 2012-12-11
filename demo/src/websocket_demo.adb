-------------------------------------------------------------------------------
--                                                                           --
--                   Copyright (C) 2010-, Thomas Løcke                   --
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
with Ada.Containers.Doubly_Linked_Lists;
with AWS.Net.WebSocket.Registry;
with AWS.Utils;
with Yolk.Log;

package body Websocket_Demo is

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

   package Object_Container is new Ada.Containers.Doubly_Linked_Lists (Object);
   use Object_Container;
   Clients : List;
   --  Every connected client is added to this list, which in turn is used by
   --  the Clocker task to send unique messages to each individual connected
   --  client.

   Rcp : constant AWS.Net.WebSocket.Registry.Recipient :=
           AWS.Net.WebSocket.Registry.Create (URI => "/websocket");
   --  Targets all clients (any Origin) whose URI is /websocket

   task Clocker is
      entry Start;
      entry Stop;
   end Clocker;
   --  The Clocker task is nothing but a simple loop that broadcasts a
   --  timestamp, the amount of connected clients and a string with 10 random
   --  characters.

   ---------------
   --  Clocker  --
   ---------------

   task body Clocker
   is
      use Yolk.Log;
   begin
      accept Start;

      Trace (Handle  => Info,
             Message => "Websocket.Clocker task started");

      loop
         select
            accept Stop;
            exit;
         or
            delay 1.0;

            AWS.Net.WebSocket.Registry.Send
              (To      => Rcp,
               Message => "timestamp|" & Ada.Calendar.Formatting.Image
                 (Ada.Calendar.Clock, True));
            --  Date broadcasted to all clients connected to /websocket

            AWS.Net.WebSocket.Registry.Send
              (To      => Rcp,
               Message => "clients_connected|" & Clients.Length'Img);
            --  Amount of clients connected broadcast to all clients connected
            --  to /websocket

            for Client of Clients loop
               Client.Send
                 (Message => "random_string|" & AWS.Utils.Random_String (10));
               --  Send a random string to a specific client connected to
               --  /websocket
            end loop;
         end select;
      end loop;

      Trace (Handle  => Info,
             Message => "Websocket.Clocker task stopped");
   exception
      when others =>
         null; --  Forget everything...
   end Clocker;

   --------------
   --  Create  --
   --------------

   function Create
     (Socket  : AWS.Net.Socket_Access;
      Request : AWS.Status.Data)
      return AWS.Net.WebSocket.Object'Class
   is
      use Yolk.Log;
   begin
      Trace (Handle  => Info,
             Message => "WebSocket created.");

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
      use AWS.Net.WebSocket;
      use Yolk.Log;

      C : Cursor := No_Element;
   begin
      for Client in Clients.Iterate loop
         if Element (Client) = Socket then
            C := Client;
            exit;
         end if;
      end loop;

      if C /= No_Element then
         Clients.Delete (C);
      end if;

      Trace (Handle  => Info,
             Message => "WebSocket closed " &
               Error_Type'Image (Socket.Error) &
               ", " & Message);
   end On_Close;

   ------------------
   --  On_Message  --
   ------------------

   overriding procedure On_Message
     (Socket  : in out Object;
      Message : in     String)
   is
      use Yolk.Log;
   begin
      Socket.Send (Message);

      Trace (Handle  => Info,
             Message => "WebSocket message received: " & Message);
   end On_Message;

   ---------------
   --  On_Open  --
   ---------------

   overriding procedure On_Open
     (Socket  : in out Object;
      Message : in     String)
   is
      use Yolk.Log;
   begin
      Clients.Append (Socket);

      Trace (Handle  => Info,
             Message => "WebSocket opened: " & Message);
   end On_Open;

   -------------
   --  Start  --
   -------------

   procedure Start
   is
   begin
      AWS.Net.WebSocket.Registry.Register
        (URI     => "/websocket",
         Factory => Websocket_Demo.Create'Access);

      Clocker.Start;
   end Start;

   ------------
   --  Stop  --
   ------------

   procedure Stop
   is
   begin
      Clocker.Stop;
   end Stop;

end Websocket_Demo;
