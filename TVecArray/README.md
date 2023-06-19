<h3>TPGLVecArray</h3>

TPGLVecArray is a generic container for dynamic arrays that mimics the behavior of the C++ std::vector class. TPGLVecArray reserves attempts to reserve more memory than the user has explicitly asked for in order to avoid reallocation of memory when new elements are requested to be added to the array. When the user requests that elements be removed, TPGLVecArray simply decrements it's Size property, reports the new Size, and restricts access elements passed [Size - 1] also in order to avoid unnecesarrily reallocating memory. The user can request that more memory be reserved, or that only the necessary amount of memory be allocated. 

Users can toggle optional bounds checking within TPGLVecArray member functions by editting the 'pgldynarray.inc' file, which contains a compiler $DEFINE (if those CPU cycles eaten by conditionals really bother you). If bounds checking is not toggled, functions will not... check bounds... and as such will not return values indicating that an element index is invalid either because it is beyond useable range of elements or beyond the range of the actual array in memory.

Additionally, the there is an option to enable RELEASE_INLINE, which is a macro dropped in place of 'inline', which will not inline functions in non-release builds.

There is currently no support of nested/multi-dimensional TPGLVecArrays. This is planned.

Currently, when TPGLVecArray internally compares element and a value, an inline function `SameBytes` is called. `SameBytes` iterates over each byte of the element and the compared value and returns `False` if they are not equal. `SameBytes` returns true if the loop finishes. `SameBytes` is implimented as

    function SameBytes(const Address1, Address2: PByte; aSize: UINT32): Boolean;
    var
    I: UINT32;
      begin
        Result := True;
        for I := 0 to aSize - 1 do begin
          if Address1[I] <> Address2[I] then Exit(False);
        end;
      end;   

The first glaringly obvious problem with this is the case in which the size of the data type is not fixed, as in strings and arrays. This method of comparison is temporary. A better method will be implemented.

##
## Types
**`TTypePointer = ^T`**
TTypePointer is a typed pointer of that type of the TPGLVecArray.
Ex. if TPGLVecArray has a type of `Byte`, then TTypePointer is equivalent to `^Byte` or `PByte`.

##
## Properties
**`Data: Pointer`** *READ ONLY*<br>
Pointer to the first element of the array. If the array has a length of 0, returns nil.

**`Element[Index: UINT32]: <T>`** *READ/WRITE*<br>
Read or write to element of array.

**`ElementData[Index: UINT32]: TTypePointer`** *READ ONLY*<br>
Pointer to the element at index `Index`.

**`TypeSize: UINT32`** *READ ONLY*<br>
The size in bytes of the array's data type.

**`Size: UINT32`** *READ ONLY*<br>
The number of useable elements of the array.

**`Capacity: UINT32`** *READ ONLY*<br>
The maximum number of useable elements that can fit in the currently allocated memory.

**`High: UINT32`** *READ ONLY*<br>
The highest useable index of the array. This is `Size - 1`. Included simply for convenience.

**`MemoryUsed: UINT32`** *READ ONLY*<br>
The amount of memory in bytes of the useable portion of the array.

**`MemoryReserved: UINT32`** *READ ONLY*<br>
The total amount of memory in bytes reserved for the array.

**`Empty: Boolean`** *READ ONLY*<br>
Returns `TRUE` if `SIZE` is 0.

##
## Constructors

**`Create(const aCapacity: UINT32)`**<br>
Creates a TPGLVecArray with a `Capacity` of `aCapacity`;

##
## Procedures

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
Changes the amount of reserved memory to `aLength * TypeSize` bytes, effectively changing `Capacity` to `aLength`.<br>
If `aLength` is <= `Size` then no operations are performed.

**`PushBack(const Value: T)`**<br>
Adds 1 useable element with a value of `Value` to the end of the array and increments `Size` by 1. If the new value of `Size` would excede `Capacity`, then memory is reallocated at twice the size needed to store the useable elements.

**`PushBack(const Values: Array of T)`**<br>
Adds a number of useable elements to the end of the array equal to the length of `Values` and increments `Size` by the same amount. If the new value of `Size` would excede `Capacity`, then memory is reallocated at twice the size needed to store the useable elements.

**`PushFront(const Value: T)`**<br>
Adds an element to the beginning of the array (index 0). The size of the array is increased by 1 and all existing elements are moved forward by 1 index. If the new `Size` would exceed `Capacity`, memory is reallocated at twice the size needed to store the useable elements.

**`PushFront(const Values: Array of T)`**<br>
Adds a number of elements equaling the length of `Values` to the beginning of the array (starting at index 0). The size of the array is increased by the length of `Values` and all existing elements are moved forward by as many indices. If the new `Size` would exceed `Capacity`, memory is reallocated at twice the size needed to store the useable elements.

**`PopBack()`**<br>
Removes 1 element from the end of the array. `Size` is decremented by 1. No memory allocation operations are performed. If `Size` is 0, `PopBack()` does nothing.

**`PopFront()`**<br>
Removes 1 element from the beginning of the array (index 0), and all other elements are moved back by 1 index. No memory allocation operations are performed. If `Size` is 0, `PopFront()` does nothing.

**`Insert(const aIndex: UINT32; const Value: array of T)`**<br>
`Values` is inserted into the array at index `aIndex`. All elements of the array starting at index `aIndex` are shifted forward by the length of `Values` and `Size` is incremented by the length of `Values`. If the new `Size` would exceed `Capacity`, then memory is reallocated at twice the size needed to store the useable elements.

**`Delete(const Index: UINT32)`**<br>
Removes 1 element from the array at index `Index`, and shifts all other elements after it back by 1. `Size` is decremented by 1. No memory operations are performed.
If `Size` is 0, `Delete()` does nothing.
If `Size` is 1, `Delete()` calles `PopBack()`.
If `Index` is `High`, `Delete()` calles `PopFront()`.

**`FindDeleteFirst(const Value: T)`**<br>
`FindDeleteFirst` iterates through the array starting at index 0 until an element with a value of `Value` is found, at which point `Delete()` is called for that element and the function exits.
If `Size` is 0, `FindDeleteFirst()` does nothing.

**`FindDeleteLast(const Value: T)`**<br>
`FindDeleteLast()` iterates backwards through the array starting at index `High` until an element with the value of `Value` is found, at which point `Delete()` is called for the element and the function exits.
if `Size` is 0, `FindDeleteLast()` does nothing.

**`FindDeleteAll(const Value: T)`**<br>
`FindDeleteAll()` iterates through the array starting at index 0 and calls `Delete()` for each element that has a value of `Value`.
if `Size` is 0, `FindDeleteAll()` does nothing.

**`Swap(aIndex1, aIndex2: UINT32)`**<br>
Swaps the values of the `Element[aIndex1]` and `Element[aIndex2]`.
if `aIndex` and `aIndex2` are the same value, then `Swap()` does nothing.
If bounds checking is enabled, then no operation is performed if `aIndex1` or `aIndex2` are greater than `High`.

**`Reverse()`**<br>
Reverses the elements of the array, as though the array had been copied to itself backwards from the highest index to index 0.

**`CopyToBuffer(var aBuffer: Pointer)`**<br>
Performs a single copy of the array data up to index `High` to the memory address contained in `aBuffer`.

**`CopyToArray(var Arr: specialize TArray<T>)`**<br>
Performs a single copy of the array data up to index `High` to `Arr`. `Arr` is set to length `Size`.

**`CopyToVecArray(var Arr: TPGLVecArray)`**<br>
Performs a single copy of the array data up to index `High` to the memory of `Arr`. `Arr`'s `Capacity` is set to `Size`.

**`Combine(var Arr: TPGLVecArray)`**<br>
Calls `Insert(Self.High, Arr.Data)`, appending `Arr`'s data to the end the array and incrementing `Size` by the `Arr.Size`. If the new `Size` would exceed `Capacity`, memory is reallocated at twice the size needed to store the number of useable elements. 

**`Combine(var Arr: specialize TArray<T>)`**<br>
Calls `Insert(Self.High, Arr)`, appending `Arr` to the end of the array and incrementing `Size` by the lenght of `Arr`. If the new `Size` would exceed `Capacity`, memory is reallocated at twice the size needed to store the numbef of useable elements.

**`OverWrite(var Arr: TPGLVecArray; aIndex: UINT32)`**<br>


**`OverWrite(var Arr: specialize TArray<T>; aIndex: UINT32)`**<br>


##
## Functions

**`FindFirst(const Value: T):`** ***INT32***<br>
Returns the lowest index element with a value of `Value`.
If no elements equal `Value`, -1 is returned.

**`FindLast(const Value: T):`** ***INT32***<br>
Returns the highest index element with a value of `Value`.
If no elements equal `Value`, -1 is returned.

**`FindAll(const Value: T):`** ***TArray<UINT32>***<br> 
Returns an array containing the indices of all elements that have a value of `Value`.
If no elements equal `Value`, a 0 length array is returned.

