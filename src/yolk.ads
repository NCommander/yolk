-------------------------------------------------------------------------------
--                                                                           --
--                                  Yolk                                     --
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
with AWS.Server;
with AWS.Services.Dispatchers.URI;

package Yolk is

   Version : constant String := "0.78";

   type Server is tagged limited private;

   function Create
     (Load_Extra_MIME_Types    : in Boolean := True;
      Register_URI_Dispatchers : in Boolean := True)
      return Server;

   procedure Start
     (S                : in out Server;
      Start_WebSockets : in Boolean := True);

private

   type Server is tagged limited
      record
         Got_Dispatchers   : Boolean := False;
         URI_Handlers      : AWS.Services.Dispatchers.URI.Handler;
         Web_Server        : AWS.Server.HTTP;
         Web_Server_Config : AWS.Config.Object;
      end record;

end Yolk;
