# fl-util
A utility library used throughout various projects of mine.

THIS IS NOT AN ADDON! INCLUDE THIS WITH YOUR PROJECT IF YOU WISH TO USE IT.

It features the following functions:

```lua
-- A function to get lowercase type of an object.
function typeof(obj)

-- A nicer wrapper for pcall.
function Try(id, func, ...)

-- An even nicer wrapper for pcall.
function try(tab)
function catch(handler)

-- A function to check whether character is vowel or not.
function util.IsVowel(char)

-- A function to remove a substring from the end of the string.
function string.RemoveTextFromEnd(str, strNeedle, bAllOccurences)

-- A function to remove a substring from the beginning of the string.
function string.RemoveTextFromStart(str, strNeedle, bAllOccurences)

-- A function to check whether all of the arguments in vararg are valid (via IsValid).
function util.Validate(...)

-- A function to include a file based on it's prefix.
function util.Include(strFile)

-- A function to include all files in a directory.
function util.IncludeDirectory(strDirectory, strBase, bIsRecursive)

-- A function to get a material. It caches the material automatically.
function util.GetMaterial(mat)

-- A function to convert a single hexadecimal digit to decimal.
function util.HexToDec(hex)

-- A function to convert hexadecimal number to decimal.
function util.HexToDecimal(hex)

-- A function to convert hexadecimal color to a color structure.
function util.HexToColor(hex)

-- A function to do C-style formatted prints.
function printf(str, ...)

-- A function to select a random player.
function player.Random()

-- A function to find player based on their name or steamID.
function player.Find(name, bCaseSensitive)

-- A function to check whether the string is full uppercase or not.
function string.IsUppercase(str)

-- A function to check whether the string is full lowercase or not.
function string.IsLowercase(str)

-- A function to find all occurences of a substring in a string.
function string.FindAll(str, pattern)

-- A function to check if string is command or not.
function string.IsCommand(str)

-- Strips the string of ID-unfriendly characters and converts it to lowercase.
function string.MakeID(str)

-- Nice wrapper for surface.GetTextSize.
function util.GetTextSize(text, font)

function util.GetTextWidth(text, font)
function util.GetTextHeight(text, font)
function util.GetFontSize(font)
function util.GetFontHeight(font)

function util.GetPanelClass(panel)

-- Adjusts x, y to fit inside x2, y2 while keeping original aspect ratio.
function util.FitToAspect(x, y, x2, y2)

function util.ToBool(value)

function util.CubicEaseIn(curStep, steps, from, to)
function util.CubicEaseOut(curStep, steps, from, to)
function util.CubicEaseInTable(steps, from, to)
function util.CubicEaseOutTable(steps, from, to)
function util.CubicEaseInOut(curStep, steps, from, to)
function util.CubicEaseInOutTable(steps, from, to)
function util.WaitForEntity(entIndex, callback, delay, waitTime)

-- A function to determine whether vector from A to B intersects with a
-- vector from C to D.
function util.VectorsIntersect(vFrom, vTo, vFrom2, vTo2)

-- A function to determine whether a 2D point is inside of a 2D polygon.
function util.VectorIsInPoly(point, polyVertices)

-- A safer way to merge two tables.
function table.SafeMerge(to, from)
```

It also adds the following functionality to Color meta table:

```lua
-- If the first argument is a hexadecimal number (as a string) - it will convert it to color.
-- If the first argument is color's name (E.G. "red") - it will convert it to color.
-- Otherwise works exactly like old Color()
function Color(r, g, b, a)

-- Darkens the original color and returns a copy of it.
function Color:Darken(nAmount)

-- Lightens the original color and returns a copy of it.
function Color:Lighten(nAmount)
```
