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

with AWS.Templates;
with Database;
with GNATCOLL.SQL;

package body View.DB_Test is

   ---------------
   --  Generate --
   ---------------

   function Generate
     (Request : in AWS.Status.Data)
      return AWS.Response.Data
   is
      use AWS.Templates;
      use Database;
      use GNATCOLL.SQL;
      use GNATCOLL.SQL.Exec;

      PostgreSQL_Conn : Database_Connection;
      SQLite_Conn     : Database_Connection;

      FC              : Forward_Cursor;

      Query_Insert_Data : constant SQL_Query := SQL_Insert
        ((Tmp.Id = Integer_Param (1)) &
         (Tmp.Name = Text_Param (2)));

      Prepared_Query_Insert_Data : constant Prepared_Statement := Prepare
        (Query => Query_Insert_Data);

      Query_Select_Data : constant SQL_Query := SQL_Select
        (Fields => Tmp.Id & Tmp.Name,
         From   => Tmp,
         Where  => Tmp.Name = Text_Param (1));

      Prepared_Query_Select_Data : constant Prepared_Statement := Prepare
        (Query => Query_Select_Data);

      Billy          : aliased String := "Billy";
      Has_Tmp_Table  : Boolean := False;

      PostgreSQL_Messages : Vector_Tag;
      SQLite_Messages     : Vector_Tag;
      T                   : Translate_Set;
   begin
      --  PostgreSQL test
      PostgreSQL_Conn := PostgreSQL_Description.Build_Connection;

      if PostgreSQL_Conn.Check_Connection then
         Insert (T, Assoc ("POSTGRESQL_SETUP", True));

         FC.Fetch (PostgreSQL_Conn,
                   "SELECT tablename " &
                     "FROM pg_tables " &
                     "WHERE schemaname = 'public' " &
                     "AND tablename = 'tmp'");

         Append (PostgreSQL_Messages, "Checking if table 'tmp' exists.");

         while FC.Has_Row loop
            Has_Tmp_Table := True;
            Append (PostgreSQL_Messages, "Table 'tmp' found.");
            exit;
         end loop;

         if not Has_Tmp_Table then
            PostgreSQL_Conn.Execute
              ("CREATE TABLE tmp (id INTEGER, name TEXT)");

            Append (PostgreSQL_Messages,
                    "Table 'tmp' not found. Creating it.");
            Append (PostgreSQL_Messages, "Table 'tmp' created.");
         end if;

         for I in Names'Range loop
            PostgreSQL_Conn.Execute (Stmt   => Prepared_Query_Insert_Data,
                                     Params => (1 => +I,
                                                2 => +Names (I)));

            Append (PostgreSQL_Messages,
                    "Added " & I'Img & ":" & Names (I).all & " to 'tmp'.");
         end loop;

         FC.Fetch (Connection => PostgreSQL_Conn,
                   Stmt       => Prepared_Query_Select_Data,
                   Params     => (1 => +Billy'Access));

         Append (PostgreSQL_Messages, "Querying 'tmp' for " & Billy & ".");

         while FC.Has_Row loop
            Append (PostgreSQL_Messages,
                    "Found "
                    & FC.Integer_Value (0)'Img
                    & ":"
                    & FC.Value (1)
                    & " pair.");
            FC.Next;
         end loop;

         PostgreSQL_Conn.Execute ("DROP TABLE tmp");

         Append (PostgreSQL_Messages, "Table 'tmp' dropped.");

         PostgreSQL_Conn.Commit_Or_Rollback;

         if PostgreSQL_Conn.Success then
            Insert (T, Assoc ("POSTGRESQL_SUCCESS", True));
            Append (PostgreSQL_Messages, "Transaction succesfully commited.");
         else
            Insert (T, Assoc ("POSTGRESQL_SUCCESS", False));
            Append (PostgreSQL_Messages, "Commit failed.");
         end if;
      else
         Insert (T, Assoc ("POSTGRESQL_SETUP", False));
      end if;

      Insert (T, Assoc ("POSTGRESQL_MESSAGES", PostgreSQL_Messages));

      Free (PostgreSQL_Conn);

      --  SQLite test
      SQLite_Conn := SQLite_Description.Build_Connection;

      for I in Names'Range loop
         SQLite_Conn.Execute (Stmt   => Prepared_Query_Insert_Data,
                              Params => (1 => +I,
                                         2 => +Names (I)));

         Append (SQLite_Messages,
                 "Added " & I'Img & ":" & Names (I).all & " to 'tmp'.");
      end loop;

      FC.Fetch (Connection => SQLite_Conn,
                Stmt       => Prepared_Query_Select_Data,
                Params     => (1 => +Billy'Access));

      Append (SQLite_Messages, "Querying 'tmp' for " & Billy & ".");

      while FC.Has_Row loop
         Append (SQLite_Messages,
                 "Found "
                 & FC.Integer_Value (0)'Img
                 & ":"
                 & FC.Value (1)
                 & " pair.");
         FC.Next;
      end loop;

      SQLite_Conn.Execute ("DELETE FROM tmp");

      SQLite_Conn.Commit_Or_Rollback;

      if SQLite_Conn.Success then
         Insert (T, Assoc ("SQLITE_SUCCESS", True));
         Append (SQLite_Messages, "Transaction succesfully commited.");
      else
         Insert (T, Assoc ("SQLITE_SUCCESS", False));
         Append (SQLite_Messages, "Commit failed.");
      end if;

      Insert (T, Assoc ("SQLITE_MESSAGES", SQLite_Messages));

      return Build_Response
        (Status_Data   => Request,
         Template_File => My.Config.Get (My.Template_DB_Test),
         Translations  => T);
   end Generate;

end View.DB_Test;
