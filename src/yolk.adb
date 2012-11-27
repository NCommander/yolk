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

with Ada.Command_Line;

package body Yolk is

   function Get_Commandline_Value
     (Parameter : in String)
      return String;
   --  Return the value associated with Parameter, ie. the value that follows
   --  immediately after Parameter in the given commandline parameters. Return
   --  empty string if Parameter doesn't exist.

   -----------------------------
   --  Get_Commandline_Value  --
   -----------------------------

   function Get_Commandline_Value
     (Parameter : in String)
      return String
   is
      use Ada.Command_Line;
   begin
      for K in 1 .. Argument_Count loop
         if Argument (K) = Parameter
           and then K < Argument_Count
         then
            return Argument (K + 1);
         end if;
      end loop;

      return "";
   end Get_Commandline_Value;

   -------------------
   --  PID_File  --
   -------------------

   function PID_File
     return String
   is
   begin
      return Get_Commandline_Value (Parameter => "--pid-file");
   end PID_File;

   ------------------------
   --  Yolk_Config_File  --
   ------------------------

   function Yolk_Config_File
     return String
   is
      Value : constant String := Get_Commandline_Value ("--yolk-config-file");
   begin
      return (if Value /= "" then Value else Default_Config_File);
   end Yolk_Config_File;

end Yolk;
