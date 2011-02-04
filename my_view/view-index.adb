-------------------------------------------------------------------------------
--                                                                           --
--                                  Yolk                                     --
--                                                                           --
--                               view.index                                  --
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

with My_Configuration;
with Rotating_Log;
with Yolk.Email.Composer;
--  with GNATCOLL.Email;
--  with GNATCOLL.Email.Utils;
--  with GNATCOLL.VFS; use GNATCOLL.VFS;
--  with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
--  with Ada.Calendar;
--  with AWS.MIME;
--  with AWS.Utils;
--  with AWS.SMTP.Client;
with Ada.Text_IO;

package body View.Index is

   ---------------
   --  Generate --
   ---------------

   function Generate
     (Request : in AWS.Status.Data)
      return AWS.Response.Data
   is

      use AWS.Templates;
      use Yolk.Email;
      use Rotating_Log;

      package My renames My_Configuration;

      T : Translate_Set;

   begin

      Track (Handle     => Info,
             Log_String => "Testing the INFO track");

      Track (Handle     => Error,
             Log_String => "Testing the ERROR track");

      Insert (T, Assoc ("HANDLER", String'(My.Config.Get (My.Handler_Index))));
      Insert (T, Assoc ("TEMPLATE",
        String'(My.Config.Get (My.Template_Index))));
      Insert (T, Assoc ("URI", AWS.Status.URI (Request)));

      declare

         Email : Structure;

      begin

         Composer.Send (ES           => Email,
                        From_Address => "thomas@responsum.dk",
                        From_Name    => "Thomas L�cke",
                        To_Address   => "thomas@12boo.net",
                        To_Name      => "Thomas L�cke",
                        Subject      => "Test text/plain email med ��� ���",
                        Text_Part    => "Test text/plain email med ��� ���",
                        SMTP_Server  => "freja.serverbox.dk",
                        Charset      => ISO_8859_1);

         if Composer.Is_Send (ES => Email) then
            Ada.Text_IO.Put_Line ("Email Send!");
         else
            Ada.Text_IO.Put_Line ("Email NOT Send!");
         end if;

         --  Use a convenience procedure to build and send an email.
         --  Send (ES             => Bn_Email,
         --        From_Address   => "thomas@responsum.dk",
         --        From_Name      => "Thomas L�cke",
         --        To_Address     => "thomas@12boo.net",
         --        To_Name        => "Thomas L�cke",
         --        Subject        => "Text Type Test ��� ���",
         --        Text_Part      => "Text Type Test ��� ���",
         --        SMTP_Server    => "freja.serverbox.dk",
         --        Charset        => ISO_8859_1);

         --  Use a convenience procedure to build and send an email.
         --  Send (ES             => Email,
         --        From_Address   => "thomas@responsum.dk",
         --        From_Name      => "Thomas L�cke",
         --        To_Address     => "thomas@12boo.net",
         --        To_Name        => "Thomas L�cke",
         --        Subject        => "Test ��� ���",
         --        Text_Part      => "Test ��� ���",
         --        HTML_Part      => "<b>Test</b> ��� ���",
         --        SMTP_Server    => "freja.serverbox.dk",
         --        Charset        => ISO_8859_1);

      exception
         when others =>
            Ada.Text_IO.Put_Line ("EMAIL PROBLEM!");
      end;

      return Build_Response
        (Status_Data   => Request,
         Template_File => My.Config.Get (My.Template_Index),
         Translations  => T);

   end Generate;

end View.Index;
