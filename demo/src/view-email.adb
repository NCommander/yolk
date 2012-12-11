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

with Ada.Strings.Fixed;
with AWS.Parameters;
with AWS.Templates;
with Yolk.Email.Composer;
with Yolk.Log;

package body View.Email is

   procedure Populate_Form
     (Address : in     String;
      Name    : in     String;
      T       :    out AWS.Templates.Translate_Set);
   --  Insert the form data associations into the T translate set.

   procedure Send_Email
     (Address : in     String;
      Name    : in     String;
      T       :    out AWS.Templates.Translate_Set);
   --  Construct and send an email to recipient.

   ---------------
   --  Generate --
   ---------------

   function Generate
     (Request : in AWS.Status.Data)
      return AWS.Response.Data
   is
      use AWS.Templates;
      use Ada.Strings;

      P       : constant AWS.Parameters.List :=
                  AWS.Status.Parameters (Request);
      Name    : constant String :=
                  Fixed.Trim (P.Get ("recip_name"), Both);
      Address : constant String :=
                  Fixed.Trim (P.Get ("recip_address"), Both);
      T       : Translate_Set;
   begin
      if Name'Length > 0
        and then Address'Length > 0
      then
         Send_Email (Address => Address,
                     Name    => Name,
                     T                 => T);
      else
         Populate_Form (Address => "yolk@mailinator.com",
                        Name    => "Zaphod Beeblebrox",
                        T                 => T);
      end if;

      return Build_Response
        (Status_Data   => Request,
         Template_File => My.Config.Get (My.Template_Email),
         Translations  => T);
   end Generate;

   ---------------------
   --  Populate_Form  --
   ---------------------

   procedure Populate_Form
     (Address : in     String;
      Name    : in     String;
      T       :    out AWS.Templates.Translate_Set)
   is
      use AWS.Templates;
   begin
      Insert (T, Assoc ("RECIP_NAME", Name));
      Insert (T, Assoc ("RECIP_ADDRESS", Address));
      Insert
        (T, Assoc ("SMTP_HOST", String'(My.Config.Get (My.SMTP_Host))));
      Insert
        (T, Assoc ("SMTP_PORT", String'(My.Config.Get (My.SMTP_Port))));
   end Populate_Form;

   ------------------
   --  Send_Email  --
   ------------------

   procedure Send_Email
     (Address : in     String;
      Name    : in     String;
      T       :    out AWS.Templates.Translate_Set)
   is
      use AWS.Templates;
      use Yolk.Email;
      use Yolk.Log;

      Email : Structure;
   begin
      if Address /= "" then
         Composer.Add_Custom_Header (ES      => Email,
                                     Name    => "User-Agent",
                                     Value   => "Yolk " & Yolk.Version);
         Composer.Send (ES           => Email,
                        From_Address => "thomas@12boo.net",
                        From_Name    => "Thomas Løcke",
                        To_Address   => Address,
                        To_Name      => Name,
                        Subject      => "Test email",
                        Text_Part    => "Test email from Yolk",
                        SMTP_Server  => My.Config.Get (My.SMTP_Host),
                        SMTP_Port    => My.Config.Get (My.SMTP_Port),
                        Charset      => UTF8);

         if Composer.Is_Send (Email) then
            Insert (T, Assoc ("IS_SEND", True));
            Insert (T, Assoc ("SMTP_HOST",
              String'(My.Config.Get (My.SMTP_Host))));

            Trace (Handle  => Info,
                   Message => "Email sent to " &
                     Address &
                     " using " &
                     String'(My.Config.Get (My.SMTP_Host)));
         else
            Insert (T, Assoc ("IS_SEND", False));
            --  Sending failed.

            Trace (Handle  => Error,
                   Message => "Email failed to " &
                     Address &
                     " using " &
                     String'(My.Config.Get (My.SMTP_Host)));

            Populate_Form (Address => Address,
                           Name    => Name,
                           T                 => T);
         end if;
      else
         Insert (T, Assoc ("IS_SEND", False));
         --  No recipient address, so obviously we cannot send the email.

         Populate_Form (Address => Address,
                        Name    => Name,
                        T                 => T);
      end if;
   end Send_Email;

end View.Email;
