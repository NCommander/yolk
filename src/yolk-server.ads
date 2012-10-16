-------------------------------------------------------------------------------
--                                                                           --
--                                  Yolk                                     --
--                                                                           --
--                               Yolk.Server                                 --
--                                                                           --
--                                  SPEC                                     --
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

with AWS.Config;
with AWS.Exceptions;
with AWS.Server;
with AWS.Services.Dispatchers.URI;

package Yolk.Server is

   type Resource_Dispatchers is not null access
     procedure (RH : out AWS.Services.Dispatchers.URI.Handler);

   type HTTP is tagged limited private;

   function Create
     (Compress_Static_Content : in Boolean := True;
      Load_Extra_MIME_Types   : in Boolean := True;
      Server_Uses_WebSockets  : in Boolean := True;
      Set_Dispatchers         : in Resource_Dispatchers;
      Unexpected              : in AWS.Exceptions.Unexpected_Exception_Handler)
      return HTTP;
   --  Create a HTTP object. This contains an AWS HTTP(S) server that is
   --  configured according to the configuration settings found in
   --  ./configuration/config.ini.
   --  Compress_Static_Content
   --    If True then delete old compressed content and create a clean
   --    directory for the compressed static content. Also set the
   --    Cache-Control header options for the static content.
   --  Load_Extra_MIME_Types
   --    If True then the ./configuration/aws.mime file is loaded. If False
   --    then the server will only recognize the default AWS MIME types.
   --  Server_Uses_WebSockets
   --    If True then the AWS WebSocket servers are started when the server is
   --    started.
   --  Set_Dispatchers
   --    Access to a procedure that set ALL the necessary URI dispatchers for
   --    the HTTP server. This includes the default callback and whatever
   --    WebSocket URI's that might need to be registered.
   --  Unexcpected
   --    Access to the unexpected exception handler.
   --
   --  NOTE:
   --  Yolk currently only supports starting one AWS server, as it reads its
   --  configuration from the Yolk.Configuration package. This means that
   --  successive calls to Create are ignored. Only one HTTP object can be
   --  active at any given point.

   procedure Start
     (WS : in out HTTP);
   --  Start the AWS HTTP(S) server.

   procedure Stop
     (WS : in out HTTP);
   --  Stop the AWS HTTP(S) server.

private

   type HTTP is tagged limited
      record
         Handle_The_Unexpected : AWS.Exceptions.Unexpected_Exception_Handler;
         Load_MIME_Types       : Boolean;
         URI_Handlers          : AWS.Services.Dispatchers.URI.Handler;
         Uses_Compressed_Cache : Boolean;
         Uses_WebSockets       : Boolean;
         Web_Server            : AWS.Server.HTTP;
         Web_Server_Config     : AWS.Config.Object;
      end record;

end Yolk.Server;
