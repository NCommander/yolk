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

--  Application specific configuration.

with Ada.Strings.Unbounded;
with Yolk.Config_File_Parser;

package My_Configuration is

   use Ada.Strings.Unbounded;

   function U
     (S : in String)
      return Unbounded_String
      renames To_Unbounded_String;

   type Keys is (DB_Host,
                 DB_Name,
                 DB_User,
                 DB_Password,
                 Handler_DB_Test,
                 Handler_Dir,
                 Handler_Email,
                 Handler_Index,
                 Handler_Session_Test,
                 Handler_Syndication,
                 Handler_Websocket,
                 SMTP_Host,
                 SMTP_Port,
                 Template_DB_Test,
                 Template_Email,
                 Template_Index,
                 Template_Session_Test,
                 Template_Websocket);
   --  The valid configuration keys.

   type Defaults_Array is array (Keys) of Unbounded_String;

   Default_Values : constant Defaults_Array :=
                      (DB_Host
                       => U ("localhost"),
                       DB_Name
                       => U ("yolk"),
                       DB_User
                       => U ("adauser"),
                       DB_Password
                       => U ("secret"),
                       Handler_DB_Test
                       => U ("/dbtest"),
                       Handler_Dir
                       => U ("^/dir/.*"),
                       Handler_Email
                       => U ("/email"),
                       Handler_Index
                       => U ("/"),
                       Handler_Session_Test
                       => U ("/sessiontest"),
                       Handler_Syndication
                       => U ("/syndication"),
                       Handler_Websocket
                       => U ("/websocket"),
                       SMTP_Host
                       => U ("localhost"),
                       SMTP_Port
                       => U ("25"),
                       Template_DB_Test
                       => U ("templates/website/database.tmpl"),
                       Template_Email
                       => U ("templates/website/email.tmpl"),
                       Template_Index
                       => U ("templates/website/index.tmpl"),
                       Template_Session_Test
                       => U ("templates/website/session_test.tmpl"),
                      Template_Websocket
                       => U ("templates/website/websocket.tmpl"));
   --  Default values for the configuration Keys. These values can be over-
   --  written by the configuration file given when instantiating the
   --  Yolk.Config_File_Parser generic.

   package Config is new Yolk.Config_File_Parser
     (Key_Type => Keys,
      Defaults_Array_Type => Defaults_Array,
      Defaults => Default_Values,
      Config_File => "configuration/my_config.ini");

end My_Configuration;
