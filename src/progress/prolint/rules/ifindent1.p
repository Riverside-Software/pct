/* ifindent1.p  Wrapper for ifindent.p to output only "major" 100-level warnings.
 *              These are the ones most likely to be bugs. The 200-level 
 *              warnings are most likely to just be bad indenting.  
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

{prolint/rules/ifindent.p &SetWarnings="ASSIGN warnings = 'Major'."}

