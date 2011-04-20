-------------------------------------------------------------------------------
--                                                                           --
--                                  Yolk                                     --
--                                                                           --
--                          Yolk.Syndication.Writer                          --
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

with Ada.Calendar.Formatting;
with Ada.Streams;
with Ada.Strings.Fixed;
with DOM.Core.Documents;
with DOM.Core.Elements;
with DOM.Core.Nodes;
with DOM.Readers;
with Input_Sources.Strings;
with Sax.Readers;
with Unicode.CES.Utf8;
with Yolk.Utilities;

package body Yolk.Syndication.Writer is

   function Atom_Date_Image
     (Time_Stamp : in Ada.Calendar.Time)
      return String;
   --  Return a string representation of the Time_Stamp time. The format is:
   --    yyyy-mm-ddThh:mm:ssZ
   --  The uppercase T and Z are requried as per the Atom specification.
   --  It is expected that the Time_Stamp is GMT.

   function Create_DOM_From_String
     (XML_String : in String)
      return DOM.Core.Document;
   --  Return a DOM document based on the given XML_String.

   ------------------
   --  Add_Author  --
   ------------------

   procedure Add_Author
     (Entr     : in out Atom_Entry;
      Name     : in     String;
      Base_URI : in     String := None;
      Email    : in     String := None;
      Language : in     String := None;
      URI      : in     String := None)
   is

      use Yolk.Utilities;

   begin

      Entr.Authors.Append
        (New_Item => Atom_Person'(Common =>
                                    Atom_Common'(Base_URI => TUS (Base_URI),
                                                 Language => TUS (Language)),
                                  Name   => TUS (Name),
                                  Email  => TUS (Email),
                                  URI    => TUS (URI)));

   end Add_Author;

   ------------------
   --  Add_Author  --
   ------------------

   procedure Add_Author
     (Feed     : in out Atom_Feed;
      Name     : in     String;
      Base_URI : in     String := None;
      Email    : in     String := None;
      Language : in     String := None;
      URI      : in     String := None)
   is

      use Yolk.Utilities;

   begin

      Feed.PAF.Add_Author
        (Value => Atom_Person'(Common =>
                                 Atom_Common'(Base_URI => TUS (Base_URI),
                                              Language => TUS (Language)),
                               Name   => TUS (Name),
                               Email  => TUS (Email),
                               URI    => TUS (URI)));

   end Add_Author;

   --------------------
   --  Add_Category  --
   --------------------

   procedure Add_Category
     (Entr     : in out Atom_Entry;
      Term     : in     String;
      Base_URI : in     String := None;
      Content  : in     String := None;
      Label    : in     String := None;
      Language : in     String := None;
      Scheme   : in     String := None)
   is

      use Yolk.Utilities;

   begin

      Entr.Categories.Append
        (New_Item => Atom_Category'(Common =>
                                      Atom_Common'(Base_URI => TUS (Base_URI),
                                                   Language => TUS (Language)),
                                    Content  => TUS (Content),
                                    Label    => TUS (Label),
                                    Scheme   => TUS (Scheme),
                                    Term     => TUS (Term)));

   end Add_Category;

   --------------------
   --  Add_Category  --
   --------------------

   procedure Add_Category
     (Feed     : in out Atom_Feed;
      Term     : in     String;
      Base_URI : in     String := None;
      Content  : in     String := None;
      Label    : in     String := None;
      Language : in     String := None;
      Scheme   : in     String := None)
   is

      use Yolk.Utilities;

   begin

      Feed.PAF.Add_Category
        (Value => Atom_Category'(Common =>
                                   Atom_Common'(Base_URI => TUS (Base_URI),
                                                Language => TUS (Language)),
                                 Content  => TUS (Content),
                                 Label    => TUS (Label),
                                 Scheme   => TUS (Scheme),
                                 Term     => TUS (Term)));

   end Add_Category;

   -----------------------
   --  Add_Contributor  --
   -----------------------

   procedure Add_Contributor
     (Entr     : in out Atom_Entry;
      Name     : in     String;
      Base_URI : in     String := None;
      Email    : in     String := None;
      Language : in     String := None;
      URI      : in     String := None)
   is

      use Yolk.Utilities;

   begin

      Entr.Contributors.Append
        (New_Item => Atom_Person'(Common =>
                                    Atom_Common'(Base_URI => TUS (Base_URI),
                                                 Language => TUS (Language)),
                                  Name   => TUS (Name),
                                  Email  => TUS (Email),
                                  URI    => TUS (URI)));

   end Add_Contributor;

   -----------------------
   --  Add_Contributor  --
   -----------------------

   procedure Add_Contributor
     (Feed     : in out Atom_Feed;
      Name     : in     String;
      Base_URI : in     String := None;
      Email    : in     String := None;
      Language : in     String := None;
      URI      : in     String := None)
   is

      use Yolk.Utilities;

   begin

      Feed.PAF.Add_Contributor
        (Value => Atom_Person'(Common =>
                                 Atom_Common'(Base_URI => TUS (Base_URI),
                                              Language => TUS (Language)),
                               Name   => TUS (Name),
                               Email  => TUS (Email),
                               URI    => TUS (URI)));

   end Add_Contributor;

   -----------------
   --  Add_Entry  --
   -----------------

   procedure Add_Entry
     (Feed : in out Atom_Feed;
      Entr : in     Atom_Entry)
   is
   begin

      Feed.PAF.Add_Entry (Value => Entr);

   end Add_Entry;

   ----------------
   --  Add_Link  --
   ----------------

   procedure Add_Link
     (Entr      : in out Atom_Entry;
      Href      : in     String;
      Base_URI  : in     String := None;
      Content   : in     String := None;
      Hreflang  : in     String := None;
      Language  : in     String := None;
      Length    : in     Natural := 0;
      Mime_Type : in     String := None;
      Rel       : in     Relation_Kind := Alternate;
      Title     : in     String := None)
   is

      use Yolk.Utilities;

   begin

      Entr.Links.Append
        (New_Item => Atom_Link'(Common =>
                                  Atom_Common'(Base_URI => TUS (Base_URI),
                                               Language => TUS (Language)),
                                Content   => TUS (Content),
                                Href      => TUS (Href),
                                Hreflang  => TUS (Hreflang),
                                Length    => Length,
                                Mime_Type => TUS (Mime_Type),
                                Rel       => Rel,
                                Title     => TUS (Title)));

   end Add_Link;

   ----------------
   --  Add_Link  --
   ----------------

   procedure Add_Link
     (Feed      : in out Atom_Feed;
      Href      : in     String;
      Base_URI  : in     String := None;
      Content   : in     String := None;
      Hreflang  : in     String := None;
      Language  : in     String := None;
      Length    : in     Natural := 0;
      Mime_Type : in     String := None;
      Rel       : in     Relation_Kind := Alternate;
      Title     : in     String := None)
   is

      use Yolk.Utilities;

   begin

      Feed.PAF.Add_Link
        (Value => Atom_Link'(Common =>
                               Atom_Common'(Base_URI => TUS (Base_URI),
                                            Language => TUS (Language)),
                             Content   => TUS (Content),
                             Href      => TUS (Href),
                             Hreflang  => TUS (Hreflang),
                             Length    => Length,
                             Mime_Type => TUS (Mime_Type),
                             Rel       => Rel,
                             Title     => TUS (Title)));

   end Add_Link;

   -----------------------
   --  Atom_Date_Image  --
   -----------------------

   function Atom_Date_Image
     (Time_Stamp : in Ada.Calendar.Time)
      return String
   is

      use Ada.Calendar;
      use Ada.Calendar.Formatting;

      Atom_Time : String (1 .. 20);

   begin

      Atom_Time (1 .. 19) := Image (Date                  => Time_Stamp,
                                    Include_Time_Fraction => False);
      Atom_Time (11) := 'T';
      Atom_Time (20) := 'Z';

      return Atom_Time;

   end Atom_Date_Image;

   ---------------------------
   --  Create_DOM_Document  --
   ---------------------------

   function Create_DOM_From_String
     (XML_String : in String)
      return DOM.Core.Document
   is

      use DOM.Core;
      use DOM.Readers;
      use Input_Sources.Strings;
      use Sax.Readers;

      Input  : String_Input;
      Reader : Tree_Reader;
      --  Doc    : Document;

   begin

      return Doc : Document do
         Open (Str      => XML_String,
               Encoding => Unicode.CES.Utf8.Utf8_Encoding,
               Input    => Input);

         Set_Feature (Parser => Reader,
                      Name   => Validation_Feature,
                      Value  => False);
         Set_Feature (Parser => Reader,
                      Name   => Namespace_Feature,
                      Value  => False);

         Parse (Parser => Reader,
                Input  => Input);

         Close (Input => Input);

         Doc := Get_Tree (Read => Reader);

      exception

         when others =>
            raise Not_Valid_XML with XML_String;

      end return;

   end Create_DOM_From_String;

   -------------------
   --  Get_XML_DOM  --
   -------------------

   function Get_XML_DOM
     (Feed : in Atom_Feed)
      return DOM.Core.Document
   is
   begin

      return Feed.PAF.Get_DOM;

   end Get_XML_DOM;

   ----------------------
   --  Get_XML_String  --
   ----------------------

   function Get_XML_String
     (Feed : in Atom_Feed)
      return String
   is

      use Yolk.Utilities;

   begin

      return Feed.PAF.Get_String;

   end Get_XML_String;

   ----------------------
   --  New_Atom_Entry  --
   ----------------------

   function New_Atom_Entry
     (Base_URI : in String := None;
      Language : in String := None)
      return Atom_Entry
   is

      use Ada.Calendar;
      use Yolk.Utilities;

   begin

      return An_Entry : Atom_Entry do
         An_Entry := (Authors       => Person_List.Empty_List,
                      Categories    => Category_List.Empty_List,
                      Common        =>
                        Atom_Common'(Base_URI => TUS (Base_URI),
                                     Language => TUS (Language)),
                      Contributors  => Person_List.Empty_List,
                      Id            =>
                        Atom_Id'(Common =>
                                   Atom_Common'(Base_URI =>
                                                  Null_Unbounded_String,
                                                Language =>
                                                  Null_Unbounded_String),
                                 URI    => Null_Unbounded_String),
                      Links         => Link_List.Empty_List,
                      Rights        =>
                        Atom_Text'(Common       =>
                                     Atom_Common'(Base_URI =>
                                                    Null_Unbounded_String,
                                                  Language =>
                                                    Null_Unbounded_String),
                                   Text_Content => Null_Unbounded_String,
                                   Text_Type    => Text),
                      Title         =>
                        Atom_Text'(Common       =>
                                     Atom_Common'(Base_URI =>
                                                    Null_Unbounded_String,
                                                  Language =>
                                                    Null_Unbounded_String),
                                   Text_Content => Null_Unbounded_String,
                                   Text_Type    => Text),
                      Updated       => Clock);

      end return;

   end New_Atom_Entry;

   ---------------------
   --  New_Atom_Feed  --
   ---------------------

   function New_Atom_Feed
     (Base_URI : in String := None;
      Language : in String := None)
      return Atom_Feed
   is

      use Yolk.Utilities;
      Common : constant Atom_Common := (Base_URI => TUS (Base_URI),
                                        Language => TUS (Language));

   begin

      return Feed : Atom_Feed do
         Feed.PAF.Set_Common (Value => Common);
      end return;

   end New_Atom_Feed;

   ------------------
   --  Set_Common  --
   ------------------

   procedure Set_Common
     (Feed     : in out Atom_Feed;
      Base_URI : in     String := None;
      Language : in     String := None)
   is

      use Yolk.Utilities;

   begin

      Feed.PAF.Set_Common (Value => Atom_Common'(Base_URI => TUS (Base_URI),
                                                 Language => TUS (Language)));

   end Set_Common;

   ---------------------
   --  Set_Generator  --
   ---------------------

   procedure Set_Generator
     (Feed     : in out Atom_Feed;
      Agent    : in     String;
      Base_URI : in     String := None;
      Language : in     String := None;
      URI      : in     String := None;
      Version  : in     String := None)
   is

      use Yolk.Utilities;

   begin

      Feed.PAF.Set_Generator
        (Value => Atom_Generator'(Agent => TUS (Agent),
                                  Common  =>
                                    Atom_Common'(Base_URI => TUS (Base_URI),
                                                 Language => TUS (Language)),
                                  URI     => TUS (URI),
                                  Version => TUS (Version)));

   end Set_Generator;

   ----------------
   --  Set_Icon  --
   ----------------

   procedure Set_Icon
     (Feed     : in out Atom_Feed;
      URI      : in     String;
      Base_URI : in     String := None;
      Language : in     String := None)
   is

      use Yolk.Utilities;

   begin

      Feed.PAF.Set_Icon
        (Value => Atom_Icon'(Common =>
                               Atom_Common'(Base_URI => TUS (Base_URI),
                                            Language => TUS (Language)),
                             URI    => TUS (URI)));

   end Set_Icon;

   --------------
   --  Set_Id  --
   --------------

   procedure Set_Id
     (Entr     : in out Atom_Entry;
      URI      : in     String;
      Base_URI : in     String := None;
      Language : in     String := None)
   is

      use Yolk.Utilities;

   begin

      Entr.Id := Atom_Id'(Common =>
                            Atom_Common'(Base_URI => TUS (Base_URI),
                                         Language => TUS (Language)),
                          URI    => TUS (URI));

   end Set_Id;

   --------------
   --  Set_Id  --
   --------------

   procedure Set_Id
     (Feed     : in out Atom_Feed;
      URI      : in     String;
      Base_URI : in     String := None;
      Language : in     String := None)
   is

      use Yolk.Utilities;

   begin

      Feed.PAF.Set_Id
        (Value => Atom_Id'(Common =>
                             Atom_Common'(Base_URI => TUS (Base_URI),
                                          Language => TUS (Language)),
                           URI    => TUS (URI)));

   end Set_Id;

   ----------------
   --  Set_Logo  --
   ----------------

   procedure Set_Logo
     (Feed     : in out Atom_Feed;
      URI      : in String;
      Base_URI : in String := None;
      Language : in String := None)
   is

      use Yolk.Utilities;

   begin

      Feed.PAF.Set_Logo
        (Value => Atom_Logo'(Common =>
                               Atom_Common'(Base_URI => TUS (Base_URI),
                                            Language => TUS (Language)),
                             URI    => TUS (URI)));

   end Set_Logo;

   ------------------
   --  Set_Rights  --
   ------------------

   procedure Set_Rights
     (Feed        : in out Atom_Feed;
      Rights      : in String;
      Base_URI    : in String := None;
      Language    : in String := None;
      Rights_Kind : in Content_Kind := Text)
   is

      use Yolk.Utilities;

   begin

      Feed.PAF.Set_Rights
        (Value => Atom_Text'(Common =>
                               Atom_Common'(Base_URI => TUS (Base_URI),
                                            Language => TUS (Language)),
                             Text_Content => TUS (Rights),
                             Text_Type    => Rights_Kind));

   end Set_Rights;

   --------------------
   --  Set_Subtitle  --
   --------------------

   procedure Set_Subtitle
     (Feed           : in out Atom_Feed;
      Subtitle       : in String;
      Base_URI       : in String := None;
      Language       : in String := None;
      Subtitle_Kind  : in Content_Kind := Text)
   is

      use Yolk.Utilities;

   begin

      Feed.PAF.Set_Subtitle
        (Value => Atom_Text'(Common =>
                               Atom_Common'(Base_URI => TUS (Base_URI),
                                            Language => TUS (Language)),
                             Text_Content => TUS (Subtitle),
                             Text_Type    => Subtitle_Kind));

   end Set_Subtitle;

   -----------------
   --  Set_Title  --
   -----------------

   procedure Set_Title
     (Feed       : in out Atom_Feed;
      Title      : in     String;
      Base_URI   : in     String := None;
      Language   : in     String := None;
      Title_Kind : in     Content_Kind := Text)
   is

      use Yolk.Utilities;

   begin

      Feed.PAF.Set_Title
        (Value => Atom_Text'(Common =>
                               Atom_Common'(Base_URI => TUS (Base_URI),
                                            Language => TUS (Language)),
                             Text_Content => TUS (Title),
                             Text_Type    => Title_Kind));

   end Set_Title;

   --------------------
   --  PT_Atom_Feed  --
   --------------------

   protected body PT_Atom_Feed is

      ------------------
      --  Add_Author  --
      ------------------

      procedure Add_Author
        (Value : in Atom_Person)
      is
      begin

         Authors.Append (Value);

      end Add_Author;

      --------------------
      --  Add_Category  --
      --------------------

      procedure Add_Category
        (Value : in Atom_Category)
      is
      begin

         Categories.Append (Value);

      end Add_Category;

      -----------------------
      --  Add_Contributor  --
      -----------------------

      procedure Add_Contributor
        (Value : in Atom_Person)
      is
      begin

         Contributors.Append (Value);

      end Add_Contributor;

      -----------------
      --  Add_Entry  --
      -----------------

      procedure Add_Entry
        (Value : in Atom_Entry)
      is
      begin

         Entries.Prepend (Value);

      end Add_Entry;

      ----------------
      --  Add_Link  --
      ----------------

      procedure Add_Link
        (Value : in Atom_Link)
      is
      begin

         Links.Append (Value);

      end Add_Link;

      ---------------
      --  Get_DOM  --
      ---------------

      function Get_DOM return DOM.Core.Document
      is

         use Ada.Calendar;
         use DOM.Core;
         use DOM.Core.Documents;
         use DOM.Core.Elements;
         use DOM.Core.Nodes;
         use Yolk.Utilities;

         Doc         : Document;
         Impl        : DOM_Implementation;
         Feed_Node   : Node;

         procedure Attribute
           (Elem  : in Node;
            Name  : in String;
            Value : in String);
         --  Add the attribute Name to Elem if Value isn't empty.

         procedure Create_Category_Elements
           (List   : in Category_List.List;
            Parent : in Node);
         --  Add atom:category elements to parent.

         procedure Create_Id_Element
           (Id     : in Atom_Id;
            Parent : in Node);
         --  Add atom:id element to parent;

         procedure Create_Link_Elements
           (List   : in Link_List.List;
            Parent : in Node);
         --  Add atom:link elements to Parent.

         procedure Create_Person_Elements
           (Elem_Name   : in String;
            List        : in Person_List.List;
            Parent      : in Node);
         --  Add atom:person elements to Parent.

         procedure Create_Text_Construct
           (Data      : in     String;
            Parent    : in out Node;
            Text_Kind : in     Content_Kind);
         --  Set the type (text/html/xhtml) and content of an atomTextConstruct
         --  element.

         -----------------
         --  Attribute  --
         -----------------

         procedure Attribute
           (Elem  : in Node;
            Name  : in String;
            Value : in String)
         is
         begin

            if Value /= "" then
               Set_Attribute (Elem  => Elem,
                              Name  => Name,
                              Value => Value);
            end if;

         end Attribute;

         --------------------------------
         --  Create_Category_Elements  --
         --------------------------------

         procedure Create_Category_Elements
           (List   : in Category_List.List;
            Parent : in Node)
         is

            A_Category     : Atom_Category;
            C              : Category_List.Cursor := List.First;
            Category_Node  : Node;

         begin

            loop
               exit when not Category_List.Has_Element (C);

               A_Category := Category_List.Element (C);

               Category_Node := Append_Child
                 (N         => Parent,
                  New_Child => Create_Element (Doc      => Doc,
                                               Tag_Name => "category"));

               Set_Attribute (Elem  => Category_Node,
                              Name  => "term",
                              Value => TS (A_Category.Term));

               Attribute (Elem  => Category_Node,
                          Name  => "base",
                          Value => TS (A_Category.Common.Base_URI));

               Attribute (Elem  => Category_Node,
                          Name  => "lang",
                          Value => TS (A_Category.Common.Language));

               Attribute (Elem  => Category_Node,
                          Name  => "label",
                          Value => TS (A_Category.Label));

               Attribute (Elem  => Category_Node,
                          Name  => "scheme",
                          Value => TS (A_Category.Scheme));

               if A_Category.Content /= Null_Unbounded_String then
                  Category_Node := Append_Child
                    (N         => Category_Node,
                     New_Child => Create_Text_Node
                       (Doc  => Doc,
                        Data => TS (A_Category.Content)));
               end if;

               Category_List.Next (C);
            end loop;

         end Create_Category_Elements;

         -------------------------
         --  Create_Id_Element  --
         -------------------------

         procedure Create_Id_Element
           (Id     : in Atom_Id;
            Parent : in Node)
         is

            Id_Node : Node;

         begin

            Id_Node := Append_Child
              (N         => Parent,
               New_Child => Create_Element (Doc      => Doc,
                                            Tag_Name => "id"));

            Attribute (Elem  => Id_Node,
                       Name  => "base",
                       Value => TS (Id.Common.Base_URI));

            Attribute (Elem  => Id_Node,
                       Name  => "lang",
                       Value => TS (Id.Common.Language));

            Id_Node := Append_Child
              (N         => Id_Node,
               New_Child => Create_Text_Node (Doc, TS (Id.URI)));

            pragma Unreferenced (Id_Node);
            --  We need this because XML/Ada have no Append_Child procedures,
            --  which obviously is annoying as hell.

         end Create_Id_Element;

         ----------------------------
         --  Create_Link_Elements  --
         ----------------------------

         procedure Create_Link_Elements
           (List   : in Link_List.List;
            Parent : in Node)
         is

            use Ada.Strings;

            A_Link      : Atom_Link;
            C           : Link_List.Cursor := List.First;
            Link_Node   : Node;

         begin

            loop
               exit when not Link_List.Has_Element (C);

               A_Link := Link_List.Element (C);

               Link_Node := Append_Child
                 (N         => Parent,
                  New_Child => Create_Element (Doc      => Doc,
                                               Tag_Name => "link"));

               case A_Link.Rel is
                  when Alternate =>
                     Set_Attribute (Elem  => Link_Node,
                                    Name  => "rel",
                                    Value => "alternate");
                  when Related =>
                     Set_Attribute (Elem  => Link_Node,
                                    Name  => "rel",
                                    Value => "related");
                  when Self =>
                     Set_Attribute (Elem  => Link_Node,
                                    Name  => "rel",
                                    Value => "self");
                  when Enclosure =>
                     Set_Attribute (Elem  => Link_Node,
                                    Name  => "rel",
                                    Value => "enclosure");
                  when Via =>
                     Set_Attribute (Elem  => Link_Node,
                                    Name  => "rel",
                                    Value => "via");
               end case;

               Set_Attribute (Elem  => Link_Node,
                              Name  => "href",
                              Value => TS (A_Link.Href));

               Attribute (Elem  => Link_Node,
                          Name  => "hreflang",
                          Value => TS (A_Link.Hreflang));

               if A_Link.Length > 0 then
                  Set_Attribute
                    (Elem  => Link_Node,
                     Name  => "length",
                     Value => Fixed.Trim
                       (Source => Natural'Image (A_Link.Length),
                        Side   => Left));
               end if;

               Attribute (Elem  => Link_Node,
                          Name  => "type",
                          Value => TS (A_Link.Mime_Type));

               Attribute (Elem  => Link_Node,
                          Name  => "title",
                          Value => TS (A_Link.Title));

               if A_Link.Content /= Null_Unbounded_String then
                  Link_Node := Append_Child
                    (N         => Link_Node,
                     New_Child => Create_Text_Node
                       (Doc  => Doc,
                        Data => TS (A_Link.Content)));
               end if;

               Link_List.Next (C);
            end loop;

         end Create_Link_Elements;

         ------------------------------
         --  Create_Person_Elements  --
         ------------------------------

         procedure Create_Person_Elements
           (Elem_Name   : in String;
            List        : in Person_List.List;
            Parent      : in Node)
         is

            A_Person    : Atom_Person;
            Person_Node : Node;
            C           : Person_List.Cursor := List.First;
            Elem_Node   : Node;

         begin

            loop
               exit when not Person_List.Has_Element (C);

               A_Person := Person_List.Element (C);

               Person_Node := Append_Child
                 (N         => Parent,
                  New_Child => Create_Element (Doc      => Doc,
                                               Tag_Name => Elem_Name));

               Attribute (Elem  => Person_Node,
                          Name  => "base",
                          Value => TS (A_Person.Common.Base_URI));

               Attribute (Elem  => Person_Node,
                          Name  => "lang",
                          Value => TS (A_Person.Common.Language));

               Elem_Node := Append_Child
                 (N         => Person_Node,
                  New_Child => Create_Element (Doc      => Doc,
                                               Tag_Name => "name"));
               Elem_Node := Append_Child
                 (N         => Elem_Node,
                  New_Child => Create_Text_Node (Doc  => Doc,
                                                 Data => TS (A_Person.Name)));

               if A_Person.Email /= Null_Unbounded_String then
                  Elem_Node := Append_Child
                    (N         => Person_Node,
                     New_Child => Create_Element (Doc      => Doc,
                                                  Tag_Name => "email"));
                  Elem_Node := Append_Child
                    (N         => Elem_Node,
                     New_Child => Create_Text_Node
                       (Doc  => Doc,
                        Data => TS (A_Person.Email)));
               end if;

               if A_Person.URI /= Null_Unbounded_String then
                  Elem_Node := Append_Child
                    (N         => Person_Node,
                     New_Child => Create_Element (Doc      => Doc,
                                                  Tag_Name => "uri"));
                  Elem_Node := Append_Child
                    (N         => Elem_Node,
                     New_Child => Create_Text_Node
                       (Doc  => Doc,
                        Data => TS (A_Person.URI)));
               end if;

               Person_List.Next (C);
            end loop;

         end Create_Person_Elements;

         -----------------------------
         --  Create_Text_Construct  --
         -----------------------------

         procedure Create_Text_Construct
           (Data      : in     String;
            Parent    : in out Node;
            Text_Kind : in     Content_Kind)
         is
         begin

            case Text_Kind is
               when Text =>
                  Set_Attribute (Elem  => Parent,
                                 Name  => "type",
                                 Value => "text");
                  Parent := Append_Child
                    (N         => Parent,
                     New_Child => Create_Text_Node
                       (Doc  => Doc,
                        Data => Data));
               when Html =>
                  Set_Attribute (Elem  => Parent,
                                 Name  => "type",
                                 Value => "html");
                  Parent := Append_Child
                    (N         => Parent,
                     New_Child => Create_Text_Node
                       (Doc  => Doc,
                        Data => Data));
               when Xhtml =>
                  Set_Attribute (Elem  => Parent,
                                 Name  => "type",
                                 Value => "xhtml");
                  Set_Attribute (Elem  => Parent,
                                 Name  => "xmlns",
                                 Value => XHTMLNS);

                  Parent := Append_Child
                    (N         => Parent,
                     New_Child => First_Child
                       (N => Create_DOM_From_String
                          (XML_String => "<div>" & Data & "</div>")));

            end case;

         end Create_Text_Construct;

      begin

         Doc := Create_Document (Implementation => Impl);

         --  feed element
         Feed_Node := Append_Child
           (N => Doc,
            New_Child => Create_Element (Doc      => Doc,
                                         Tag_Name => "feed"));

         Set_Attribute (Elem  => Feed_Node,
                        Name  => "xmlns",
                        Value => XMLNS);

         Attribute (Elem  => Feed_Node,
                    Name  => "base",
                    Value => TS (Common.Base_URI));

         Attribute (Elem  => Feed_Node,
                    Name  => "lang",
                    Value => TS (Common.Language));

         --  feed:id element
         Create_Id_Element (Id     => Id,
                            Parent => Feed_Node);

         --  feed:updated element
         Add_Updated_To_DOM :
         declare

            Updated_Node : Node;

         begin

            Updated_Node := Append_Child
              (N         => Feed_Node,
               New_Child => Create_Element (Doc      => Doc,
                                            Tag_Name => "updated"));

            Updated_Node := Append_Child
              (N         => Updated_Node,
               New_Child => Create_Text_Node
                 (Doc  => Doc,
                  Data => Atom_Date_Image (Time_Stamp => Clock)));

            pragma Unreferenced (Updated_Node);
            --  We need this because XML/Ada have no Append_Child procedures,
            --  which obviously is annoying as hell.

         end Add_Updated_To_DOM;

         --  feed:title element
         Add_Title_To_DOM :
         declare

            Title_Node  : Node;

         begin

            Title_Node := Append_Child
              (N         => Feed_Node,
               New_Child => Create_Element (Doc      => Doc,
                                            Tag_Name => "title"));

            Attribute (Elem  => Title_Node,
                       Name  => "base",
                       Value => TS (Title.Common.Base_URI));

            Attribute (Elem  => Title_Node,
                       Name  => "lang",
                       Value => TS (Title.Common.Language));

            Create_Text_Construct (Parent    => Title_Node,
                                   Text_Kind => Title.Text_Type,
                                   Data      => TS (Title.Text_Content));

         end Add_Title_To_DOM;

         --  feed:author elements
         Create_Person_Elements (Elem_Name   => "author",
                                 List        => Authors,
                                 Parent      => Feed_Node);

         --  feed:category elements
         Create_Category_Elements (List   => Categories,
                                   Parent => Feed_Node);

         --  feed:contributor elements
         Create_Person_Elements (Elem_Name   => "contributor",
                                 List        => Contributors,
                                 Parent      => Feed_Node);

         --  feed:generator element
         if Generator.Agent /= Null_Unbounded_String then
            Add_Generator_To_DOM :
            declare

               Generator_Node : Node;

            begin

               Generator_Node := Append_Child
                 (N         => Feed_Node,
                  New_Child => Create_Element (Doc      => Doc,
                                               Tag_Name => "generator"));

               Attribute (Elem  => Generator_Node,
                          Name  => "base",
                          Value => TS (Generator.Common.Base_URI));

               Attribute (Elem  => Generator_Node,
                          Name  => "lang",
                          Value => TS (Generator.Common.Language));

               Attribute (Elem  => Generator_Node,
                          Name  => "uri",
                          Value => TS (Generator.URI));

               Attribute (Elem  => Generator_Node,
                          Name  => "version",
                          Value => TS (Generator.Version));

               Generator_Node := Append_Child
                 (N         => Generator_Node,
                  New_Child => Create_Text_Node
                    (Doc  => Doc,
                     Data => TS (Generator.Agent)));

            end Add_Generator_To_DOM;
         end if;

         --  feed:icon element
         if Icon.URI /= Null_Unbounded_String then
            Add_Icon_To_DOM :
            declare

               Icon_Node : Node;

            begin

               Icon_Node := Append_Child
                 (N         => Feed_Node,
                  New_Child => Create_Element (Doc      => Doc,
                                               Tag_Name => "icon"));

               Attribute (Elem  => Icon_Node,
                          Name  => "base",
                          Value => TS (Icon.Common.Base_URI));

               Attribute (Elem  => Icon_Node,
                          Name  => "lang",
                          Value => TS (Icon.Common.Language));

               Icon_Node := Append_Child
                 (N         => Icon_Node,
                  New_Child => Create_Text_Node (Doc  => Doc,
                                                 Data => TS (Icon.URI)));

            end Add_Icon_To_DOM;
         end if;

         --  feed:link elements
         Create_Link_Elements (List   => Links,
                               Parent => Feed_Node);

         --  feed:logo
         Add_Logo_To_DOM :
         declare

            Logo_Node : Node;

         begin

            Logo_Node := Append_Child
              (N         => Feed_Node,
               New_Child => Create_Element (Doc      => Doc,
                                            Tag_Name => "logo"));

            Attribute (Elem  => Logo_Node,
                       Name  => "base",
                       Value => TS (Logo.Common.Base_URI));

            Attribute (Elem  => Logo_Node,
                       Name  => "lang",
                       Value => TS (Logo.Common.Language));

            Logo_Node := Append_Child
              (N         => Logo_Node,
               New_Child => Create_Text_Node (Doc  => Doc,
                                              Data => TS (Logo.URI)));

            pragma Unreferenced (Logo_Node);
            --  We need this because XML/Ada have no Append_Child procedures,
            --  which obviously is annoying as hell.

         end Add_Logo_To_DOM;

         --  feed:rights
         Add_Rights_To_DOM :
         declare

            Rights_Node : Node;

         begin

            Rights_Node := Append_Child
              (N         => Feed_Node,
               New_Child => Create_Element (Doc      => Doc,
                                            Tag_Name => "rights"));

            Attribute (Elem  => Rights_Node,
                       Name  => "base",
                       Value => TS (Rights.Common.Base_URI));

            Attribute (Elem  => Rights_Node,
                       Name  => "lang",
                       Value => TS (Rights.Common.Language));

            Create_Text_Construct (Parent    => Rights_Node,
                                   Text_Kind => Rights.Text_Type,
                                   Data      => TS (Rights.Text_Content));

         end Add_Rights_To_DOM;

         --  feed:subtitle
         Add_Subtitle_To_DOM :
         declare

            Subtitle_Node : Node;

         begin

            Subtitle_Node := Append_Child
              (N         => Feed_Node,
               New_Child => Create_Element (Doc      => Doc,
                                            Tag_Name => "subtitle"));

            Attribute (Elem  => Subtitle_Node,
                       Name  => "base",
                       Value => TS (Subtitle.Common.Base_URI));

            Attribute (Elem  => Subtitle_Node,
                       Name  => "lang",
                       Value => TS (Subtitle.Common.Language));

            Create_Text_Construct (Parent    => Subtitle_Node,
                                   Text_Kind => Subtitle.Text_Type,
                                   Data      => TS (Subtitle.Text_Content));

         end Add_Subtitle_To_DOM;

         --  feed:entry
         Add_Entries_To_DOM :
         declare

            An_Entry    : Atom_Entry;
            C           : Entry_List.Cursor := Entries.First;
            Entry_Node  : Node;

         begin

            loop
               exit when not Entry_List.Has_Element (C);

               An_Entry := Entry_List.Element (C);

               Entry_Node := Append_Child
                 (N         => Feed_Node,
                  New_Child => Create_Element (Doc      => Doc,
                                               Tag_Name => "entry"));

               Attribute (Elem  => Entry_Node,
                          Name  => "base",
                          Value => TS (An_Entry.Common.Base_URI));

               Attribute (Elem  => Entry_Node,
                          Name  => "lang",
                          Value => TS (An_Entry.Common.Language));

               --  entry:author elements
               Create_Person_Elements (Elem_Name => "author",
                                       List      => An_Entry.Authors,
                                       Parent    => Entry_Node);

               --  entry:cateory elements
               Create_Category_Elements (List   => An_Entry.Categories,
                                         Parent => Entry_Node);

               --  entry:contributor elements
               Create_Person_Elements (Elem_Name => "contributor",
                                       List      => An_Entry.Contributors,
                                       Parent    => Entry_Node);

               --  entry:id element
               Create_Id_Element (Id     => An_Entry.Id,
                                  Parent => Entry_Node);

               --  entry:link elements
               Create_Link_Elements (List   => An_Entry.Links,
                                     Parent => Entry_Node);

               Entry_List.Next (C);
            end loop;

         end Add_Entries_To_DOM;

         return Doc;

      end Get_DOM;

      ------------------
      --  Get_String  --
      ------------------

      function Get_String return String
      is

         use Ada.Streams;
         use DOM.Core.Nodes;
         use Yolk.Utilities;

         type String_Stream_Type is new Root_Stream_Type with record
            Str        : Unbounded_String;
            Read_Index : Natural := 1;
         end record;

         procedure Read
           (Stream : in out String_Stream_Type;
            Item   :    out Stream_Element_Array;
            Last   :    out Stream_Element_Offset);

         procedure Write
           (Stream : in out String_Stream_Type;
            Item   : Stream_Element_Array);

         ----------
         -- Read --
         ----------

         procedure Read
           (Stream : in out String_Stream_Type;
            Item   :    out Stream_Element_Array;
            Last   :    out Stream_Element_Offset)
         is

            Str : constant String := Slice
              (Stream.Str,
               Stream.Read_Index,
               Stream.Read_Index + Item'Length - 1);
            J   : Stream_Element_Offset := Item'First;

         begin

            for S in Str'Range loop
               Item (J) := Stream_Element (Character'Pos (Str (S)));
               J := J + 1;
            end loop;

            Last := Item'First + Str'Length - 1;
            Stream.Read_Index := Stream.Read_Index + Item'Length;

         end Read;

         -----------
         -- Write --
         -----------

         procedure Write
           (Stream : in out String_Stream_Type;
            Item   : Stream_Element_Array)
         is

            Str : String (1 .. Integer (Item'Length));
            S   : Integer := Str'First;

         begin

            for J in Item'Range loop
               Str (S) := Character'Val (Item (J));
               S := S + 1;
            end loop;

            Append (Stream.Str, Str);

         end Write;

         Output   : aliased String_Stream_Type;
         Doc      : DOM.Core.Document := Get_DOM;

      begin

         DOM.Core.Nodes.Write (Stream        => Output'Access,
                               N             => Doc,
                               Pretty_Print  => True);

         Free (Doc);

         return TS (Output.Str);

      end Get_String;

      ------------------
      --  Set_Common  --
      ------------------

      procedure Set_Common
        (Value : in Atom_Common)
      is
      begin

         Common := Value;

      end Set_Common;

      ---------------------
      --  Set_Generator  --
      ---------------------

      procedure Set_Generator
        (Value : in Atom_Generator)
      is
      begin

         Generator := Value;

      end Set_Generator;

      ----------------
      --  Set_Icon  --
      ----------------

      procedure Set_Icon
        (Value : in Atom_Icon)
      is
      begin

         Icon := Value;

      end Set_Icon;

      --------------
      --  Set_Id  --
      --------------

      procedure Set_Id
        (Value : in Atom_Id)
      is

         use Yolk.Utilities;

      begin

         Id := Value;

      end Set_Id;

      ----------------
      --  Set_Logo  --
      ----------------

      procedure Set_Logo
        (Value : in Atom_Logo)
      is
      begin

         Logo := Value;

      end Set_Logo;

      ------------------
      --  Set_Rights  --
      ------------------

      procedure Set_Rights
        (Value : in Atom_Text)
      is
      begin

         Rights := Value;

      end Set_Rights;

      --------------------
      --  Set_Subtitle  --
      --------------------

      procedure Set_Subtitle
        (Value : in Atom_Text)
      is
      begin

         Subtitle := Value;

      end Set_Subtitle;

      -----------------
      --  Set_Title  --
      -----------------

      procedure Set_Title
        (Value : Atom_Text)
      is
      begin

         Title := Value;

      end Set_Title;

      -------------------
      --  Set_Updated  --
      -------------------

      procedure Set_Updated_Time
        (Value : in Ada.Calendar.Time)
      is

         use Ada.Calendar;

      begin

         if Value > Updated then
            Updated := Value;
         end if;

      end Set_Updated_Time;

   end PT_Atom_Feed;

end Yolk.Syndication.Writer;
