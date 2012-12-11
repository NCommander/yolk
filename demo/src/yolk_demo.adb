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

--  Feel free to use this demo application as the foundation for your own
--  applications.
--
--  Usually you just have to change the name of environment task and  the name
--  of the file itself to match whatever you want to call your application.

with Ada.Exceptions;
with My_Handlers;
with Websocket_Demo;
with Yolk.Configuration;
with Yolk.Log;
with Yolk.Process_Control;
with Yolk.Process_Owner;
with Yolk.Server;
with Yolk.Whoops;

procedure Yolk_Demo is
   use Ada.Exceptions;
   use Yolk.Configuration;
   use Yolk.Log;
   use Yolk.Process_Control;
   use Yolk.Process_Owner;
   use Yolk.Server;

   Web_Server : HTTP := Create
     (Unexpected => Yolk.Whoops.Unexpected_Exception_Handler'Access);
begin
   Set_User (Username => Config.Get (Yolk_User));
   --  Switch user.

   Web_Server.Start (Dispatchers => My_Handlers.Get);
   --  Start the HTTP server.

   Websocket_Demo.Start;
   --  Start the WebSocket demo.

   Wait;
   --  This is the main "loop". We will wait here as long as the
   --  Yolk.Process_Control.Controller.Check entry barrier is False.

   Web_Server.Stop;
   --  Stop the HTTP server.

   Websocket_Demo.Stop;
   --  Stop the WebSocket demo.
exception
   when Event : others =>
      Trace (Handle  => Error,
             Message => Exception_Information (Event));
      --  Write the exception information to the rotating Error log trace.
      Web_Server.Stop;
      Websocket_Demo.Stop;
end Yolk_Demo;
