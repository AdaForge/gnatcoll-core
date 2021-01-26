------------------------------------------------------------------------------
--                             G N A T C O L L                              --
--                                                                          --
--                     Copyright (C) 2021, AdaCore                          --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
------------------------------------------------------------------------------

--  GNATCOLL.WString_List_Builders expose an API to create easily list of
--  wide strings that can be easily exported to a C wchar** or a C environment
--  block (i.e: concatenation of N C wchar strings followed by a double null
--  character).

with GNATCOLL.OS;
with Ada.Strings.UTF_Encoding;
with System;

package GNATCOLL.WString_List_Builders is

   package OS renames GNATCOLL.OS;
   package UTF8 renames Ada.Strings.UTF_Encoding;

   type WString_List_Builder is limited private;
   --  WString_List_Builder is an efficient unbounded structure to create list
   --  of strings by aggregation. The structure also allow export to **wchar
   --  in C without reallocation.

   procedure Append (Self : in out WString_List_Builder;
                     Item : UTF8.UTF_8_String);
   --  Append string Item to Self.

   procedure Append (Self  : in out WString_List_Builder;
                     Other : WString_List_Builder);
   --  Append builder Other to Self.

   procedure Append (Self : in out WString_List_Builder; Item : Wide_String);
   --  Append srtring Item to Self.

   procedure Delete (Self : in out WString_List_Builder; Index : Positive);
   --  Remove Index(th) element from Self.

   function Length (Self : WString_List_Builder) return Natural
   with Inline => True;
   --  Return number of elements stored

   function Element
      (Self  : WString_List_Builder; Index : Positive) return Wide_String
   with Inline => True;
   --  Return Index(th) element of the list as a string

   function Element
      (Self : WString_List_Builder; Index : Positive) return OS.C_WString
   with Inline => True;
   --  Return Index(th) element of the list as a char* C string

   procedure Deallocate (Self : in out WString_List_Builder);
   --  Free memory used by Self (reseting Self to the empty list).

   function As_C_WString_Array
      (Self : WString_List_Builder) return OS.C_WString_Array;
   --  Return the address to the "char**" representation of the
   --  structure.

   function As_C_WString (Self : WString_List_Builder) return OS.C_WString;
   --  Return the address to a block of C strings. A block consists of
   --  a null-terminated block of null-terminated strings

private

   type WString_Access is access Wide_String;

   type Element_Addrs is array (Natural range <>) of System.Address;
   type Element_Addrs_Access is access Element_Addrs;

   type WString_List_Builder is limited record
      Addrs      : Element_Addrs_Access := null;
      Addrs_Last : Natural              := 0;
      Str        : WString_Access       := null;
      Str_Last   : Natural              := 0;
   end record;

end GNATCOLL.WString_List_Builders;
