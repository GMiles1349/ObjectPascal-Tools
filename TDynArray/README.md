<h3>TDynArray</h3>

TDynArray is a generic container for dynamic arrays that mimics the behavior of the C++ std::vector class. TDynArray reserves attempts to reserve more memory than the user has explicitly asked for in order to avoid reallocation of memory when new elements are requested to be added to the array. When the user requests that elements be removed, TDynArray simply decrements it's Size property, reports the new Size, and restricts access elements passed [Size - 1] also in order to avoid unnecesarrily reallocating memory. The user can request that more memory be reserved, or that only the necessary amount of memory be allocated. Users can also toggle optional bounds checking within TDynArray member functions by editting the 'pgldynarray.inc' file, which contains a compiler $DEFINE (if those CPU cycles eaten by conditionals really bother you).

#### Properties
**`Data: Pointer`** *READ ONLY*<br>
Pointer to the first element of the array. If the array has a length of 0, returns nil.

**`Element[Index: UINT32]: <T>`** *READ/WRITE*<br>
Read or write to element of array.

**`TypeSize: UINT32`** *READ ONLY*<br>
The size in bytes of the array's data type.

**`Size: UINT32`** *READ ONLY*<br>
The number of useable elements of the array.

**`MaxSize: UINT32`** *READ ONLY*<br>
The maximum number of useable elements that can fit in the currently allocated memory.

**`High: UINT32`** *READ ONLY*<br>
The highest useable index of the array. This is `Size - 1`. Included simply for convenience.

**`MemoryUsed: UINT32`** *READ ONLY*<br>
The amount of memory in bytes of the useable portion of the array.

**`MemoryReserved: UINT32`** *READ ONLY*<br>
The total amount of memory in bytes reserved for the array.

**`Empty: Boolean`** *READ ONLY*<br>
Returns `TRUE` if `SIZE` is 0.

#### Constructors
**`Create(const aNumElements: UINT32)`**<br>
Creates a TDynArray with aNumElements useable elements. Allocated memory is twice the size needed to store the elements.

**`Create(const aNumElements: UINT32; const aDefaultValue: T)`**<br>
Creates a TDynArray with aNumElements useable elements initialized to aDefualtValue. Allocated memory is twice the size needed to store the elements.

#### Procedures

**`Resize(const aLength: UINT32)`**<br>
Adjusts the number of useable elements to aLength. If `aLength` is <= the current `Size`, no memory operations are made. If `aLength` is > `Size`, memory is reallocated as twice the amount needed to store the elements.

**`TrimBack(const aCount: UINT32)`**<br>
Removes `aCount` useable elements from the end of the array. If `aCount` is 1, the effect is the same as calling `PopBack`. If `aCount` is > `Size` the number of useable elements is set to 0. 

**`TrimFront(const aCount: UINT32)`**<br>
Removes `aCount` useable elements from the beginning of the array. If `aCount` is 1, the effect is the same as calling `PopFont`. If `aCount` is > `Size` the number of useable elements is set to 0. 

**`TrimRange(const aStartIndex, aEndIndex: UINT32)`**<br>
Removes useable elements from the array in the range of `aStartIndex` to `aEndIndex` inclusive. If size of the range is 1, the effect is the same as calling `Delete(aStartIndex)`.<br>
If `aStartIndex` is > `High`, `TrimRange` has no effect.<br>
if `aEndIndex` is > `High` its value is set to the value of `High`.

**`ShrinkToSize()`**<br>
Reallocates memory to only that amount necessary to store the number of useable elements.

**`Reserve(const aLength: UINT32)`**<br>
Changes the amount of reserved memory to `aLength * TypeSize` bytes, effectively changing `MaxSize` to `aLength`.<br>
If `aLength` is <= `Size` then no operations are performed.

**`PushBack(const Value: T)`**<br>
Adds 1 useable element with a value of `Value` to the end of the array and increments `Size` by 1. If the new value of `Size` would excede `MaxSize`, then memory is reallocated at twice the size needed to store the useable elements.

**`PushBack(const Values: Array of T)`**<br>
Adds a number of useable elements to the end of the array equal to the length of `Values` and increments `Size` by the same amount. If the new value of `Size` would excede `MaxSize`, then memory is reallocated at twice the size needed to store the useable elements.

**`PushFront(const Value: T)`**<br>

**`PushFront(const Values: Array of T)`**<br>

**`PopBack()`**<br>

**`PopFront()`**<br>

**`Insert(const aIndex: UINT32; const Value: array of T)`**<br>

**`Delete(const Index: UINT32)`**<br>

**`FindDeleteFirst(const Value: T)`**<br>

**`FindDeleteLast(const Value: T)`**<br>

**`FindDeleteAll(const Value: T)`**<br>

**`FindFirst(const Value: T): INT32`**<br>

**`FindLast(const Value: T): INT32`**<br>

**`FindAll(const Value: T): TArray<UINT32>`**<br> 

