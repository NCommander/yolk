-------------------------------------------------------------------------------
--                                                                           --
--                                  Yolk                                     --
--                                                                           --
--                               View.Syndication                                  --
--                                                                           --
--                                  BODY                                     --
--                                                                           --
--                   Copyright (C) 2010-2011, Thomas L�cke                   --
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

-------------------------------------------------------------------------------
--                                                                           --
--                            DEMO FILE                                      --
--                                                                           --
-------------------------------------------------------------------------------

--  This is a DEMO file. You can either move this to the my_view/ directory and
--  change it according to you own needs, or you can provide your own.
--
--  This package is currently only "with'ed" by other demo source files. It is
--  NOT required by Yolk in any way.

with AWS.Messages;
with AWS.MIME;
with Ada.Text_IO;

package body View.Syndication is

   ---------------
   --  Generate --
   ---------------

   function Generate
     (Request : in AWS.Status.Data)
      return AWS.Response.Data
   is

      use AWS.Messages;
      use AWS.MIME;
      use AWS.Response;
      use AWS.Status;

      Encoding : Content_Encoding := Identity;
      --  Default to no encoding.

   begin

      if Is_Supported (Request, GZip) then
         Encoding := GZip;
         --  GZip is supported by the client.
      end if;

      return Build (Content_Type  => Text_XML,
                    Message_Body  => Get_XML_String (Feed),
                    Encoding      => Encoding);

   end Generate;

begin

   Add_Author (Feed     => Feed,
               Name     => "Thomas Locke");
   Add_Category (Feed     => Feed,
                 Term     => "Some Term");
   Add_Contributor (Feed => Feed,
                    Name => "Trine Locke");
   Set_Generator (Feed => Feed,
                  Agent => "Yolk Syndication",
                  Base_URI => "/",
                  Language => "da",
                  URI      => "/some/uri",
                  Version  => "0.21");

   Set_Icon (Feed     => Feed,
             URI      => "icon URI");

exception

   when others =>
      Ada.Text_IO.Put_Line ("crap!");

end View.Syndication;