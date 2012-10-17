-------------------------------------------------------------------------------
--                                                                           --
--                                  Yolk                                     --
--                                                                           --
--                               My_Handlers                                 --
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

with AWS.Dispatchers.Callback;
with AWS.Net.WebSocket.Registry;
with My_Configuration;
with View.DB_Test;
with View.Dir;
with View.Email;
with Yolk.Handlers;
with View.Index;
with View.Session_Test;
with View.Syndication;
with View.Websocket;
with Websocket_Demo;
with Yolk.Not_Found;

package body My_Handlers is

   -----------
   --  Set  --
   -----------

   procedure Set
     (RH : out AWS.Services.Dispatchers.URI.Handler)
   is
      use AWS.Dispatchers.Callback;
      use My_Configuration;
      use Yolk;
   begin
      -----------------------------------------
      --  Unknown Resource (404) Dispatcher  --
      -----------------------------------------

      RH.Register_Default_Callback
        (Action => Create (Callback => Not_Found.Generate'Access));
      --  This dispatcher is called if the requested resource doesn't match any
      --  of the other dispatchers.
      --  It returns a generic 404 HTML page. The template for this 404 can be
      --  found in templates/system.
      --  Another option is of course to use this default callback for your
      --  main content, so if unknown resources are called, then the main
      --  content of the website is used. I personally prefer giving back 404's
      --  if unknown content is requested by a client.

      -----------------------------------
      --  General Content Dispatchers  --
      -----------------------------------

      --  These dispatchers handle the "page" content.
      --  NOTE:
      --    Order matters. The first handler that matches a resource handles
      --    the request.

      RH.Register
        (URI    => Config.Get (Handler_DB_Test),
         Action => Create (Callback => View.DB_Test.Generate'Access));

      RH.Register_Regexp
        (URI    => Config.Get (Handler_Dir),
         Action => Create (Callback => View.Dir.Generate'Access));

      RH.Register
        (URI    => Config.Get (Handler_Email),
         Action => Create (Callback => View.Email.Generate'Access));

      RH.Register
        (URI    => Config.Get (Handler_Index),
         Action => Create (Callback => View.Index.Generate'Access));

      RH.Register
        (URI    => Config.Get (Handler_Session_Test),
         Action => Create (Callback => View.Session_Test.Generate'Access));

      RH.Register
        (URI    => Config.Get (Handler_Syndication),
         Action => Create (Callback => View.Syndication.Generate'Access));

      RH.Register
        (URI    => Config.Get (Handler_Websocket),
         Action => Create (Callback => View.Websocket.Generate'Access));

      Handlers.Set (RH);
      --  Set the generic content handlers defined in Yolk.Handlers.

      --------------------------
      --  WebSocket handlers  --
      --------------------------

      AWS.Net.WebSocket.Registry.Register
        (URI     => "/websocket",
         Factory => Websocket_Demo.Create'Access);
   end Set;

end My_Handlers;
