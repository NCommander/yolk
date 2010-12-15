-------------------------------------------------------------------------------
--                                                                           --
--                                  Yolk                                     --
--                                                                           --
--                                  view                                     --
--                                                                           --
--                                  BODY                                     --
--                                                                           --
--                     Copyright (C) 2010, Thomas L�cke                      --
--                                                                           --
--  Yolk is free software;  you can  redistribute it  and/or modify it under --
--  terms of the  GNU General Public License as published  by the Free Soft- --
--  ware  Foundation;  either version 2,  or (at your option) any later ver- --
--  sion.  Yolk is distributed in the hope that it will be useful, but WITH- --
--  OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
--  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
--  for  more details.  You should have  received  a copy of the GNU General --
--  Public License  distributed with Yolk.  If not, write  to  the  Free     --
--  Software Foundation,  51  Franklin  Street,  Fifth  Floor, Boston,       --
--  MA 02110 - 1301, USA.                                                    --
--                                                                           --
-------------------------------------------------------------------------------

with AWS.MIME;

package body View is

   ----------------------
   --  Build_Response  --
   ----------------------

   function Build_Response (Template_File : in String;
                            Translations  : in AWS.Templates.Translate_Set)
                            return AWS.Response.Data
   is

      use AWS.Templates;

      Content : AWS.Response.Data;

   begin

      Content := AWS.Response.Build
        (Content_Type => AWS.MIME.Text_HTML,
         Message_Body => Parse
           (Filename     => Template_File,
            Translations => Translations,
            Cached       => True));
      return Content;

   end Build_Response;

end View;
