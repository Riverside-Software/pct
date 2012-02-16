/* ifindent2.p  Wrapper for ifindent.p to output only the "minor" 200-level 
 *              warnings. They are most likely to be just bad indenting - mostly 
 *              style problems. The other wrapper, ifindent1.p, outputs 100-level 
 *              warnings. These are the ones most likely to be bugs. 
    -----------------------------------------------------------------

    Copyright (C) 2002 Judy Hoffman Green

    This file is part of Prolint.

    Prolint is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    Prolint is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Prolint; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    -----------------------------------------------------------------
 */

{prolint/rules/ifindent.p &SetWarnings="ASSIGN warnings = 'Minor'."}

