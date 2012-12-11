-------------------------------------------------------------------------------
--                                                                           --
--                   Copyright (C) 2010-, Thomas Løcke                   --
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

--  Static content such as images, HTML and XML files are handled here. The
--  paths to where the server is supposed to look for the content is defined
--  by the WWW_Root configuration parameter.
--  Compressed content is saved in the Compressed_Static_Content_Cache
--  directory.

with AWS.Messages;
with AWS.Response;
with AWS.Status;

package Yolk.Static_Content is

   function Compressable
     (Request : in AWS.Status.Data)
      return AWS.Response.Data;
   --  Return compressed content. This function saves a pre-compressed version
   --  in the Compressed_Static_Content_Cache directory of the requested
   --  resource for future use. This compressed file times out according to the
   --  Compressed_Static_Content_Max_Age configuration setting.
   --
   --  Note:
   --  You can call this despite having set the Compress_Static_Content
   --  configuration parameter to False. It will still try to save a compressed
   --  version of the requested resource in the Compressed_Static_Content_Cache
   --  directory.

   function Non_Compressable
     (Request : in AWS.Status.Data)
      return AWS.Response.Data;
   --  Return non-compressed content.

   procedure Set_Cache_Options
     (No_Cache          : in Boolean := False;
      No_Store          : in Boolean := False;
      No_Transform      : in Boolean := False;
      Max_Age           : in AWS.Messages.Delta_Seconds := 86400;
      S_Max_Age         : in AWS.Messages.Delta_Seconds := AWS.Messages.Unset;
      Public            : in Boolean := False;
      Must_Revalidate   : in Boolean := True;
      Proxy_Revalidate  : in Boolean := False);
   --  Set the response cache options. If you've started your server using the
   --  Yolk.Server package, then the response cache options for static content
   --  has been set using the default values in the Static_Content_Cache_Setup
   --  call. If this is not what you need, you can change the defaults using
   --  this procedure.

   procedure Static_Content_Cache_Setup
     (No_Cache          : in Boolean := False;
      No_Store          : in Boolean := False;
      No_Transform      : in Boolean := False;
      Max_Age           : in AWS.Messages.Delta_Seconds := 86400;
      S_Max_Age         : in AWS.Messages.Delta_Seconds := AWS.Messages.Unset;
      Public            : in Boolean := False;
      Must_Revalidate   : in Boolean := True;
      Proxy_Revalidate  : in Boolean := False);
   --  Set the response cache options and delete and re-create the
   --  Compressed_Static_Content_Cache.
   --  This procedure is called automatically if you use the Yolk.Server
   --  package to create and start your server and the Compress_Static_Content
   --  configuration parameter is True.
   --  Should preferably be called before any AWS HTTP servers are started.
   --  This is a threadsafe operation, and it can be repeated as often as
   --  need be.

end Yolk.Static_Content;
