<h3>TDynArray</h3>

TDynArray is a generic container for dynamic arrays that mimics the behavior of the C++ std::vector class. TDynArray reserves attempts to reserve more memory than the user has explicitly asked for in order to avoid reallocation of memory when new elements are requested to be added to the array. When the user requests that elements be removed, TDynArray simply decrements it's Size property, reports the new Size, and restricts access elements passed [Size - 1] also in order to avoid unnecesarrily reallocating memory. The user can request that more memory be reserved, or that only the necessary amount of memory be allocated. Users can also toggle optional bounds checking within TDynArray member functions by editting the 'pgldynarray.inc' file, which contains a compiler $DEFINE (if those CPU cycles eaten by conditionals really bother you).

#### Properties
`Data: Pointer` **READ ONLY**<br>
Pointer to the first element of the array. If the array has a length of 0, returns nil.

`Element[Index: UINT32]: <T>` **READ/WRITE**<br>
Read or write to element of array.

`TypeSize: UINT32` **READ ONLY**<br>
The size in bytes of the array's data type.

`Size: UINT32` **READ ONLY**<br>
The number of useable elements of the array.

`MaxSize: UINT32` **READ ONLY**<br>
The maximum number of useable elements that can fit in the currently allocated memory.

`High: UINT32` **READ ONLY**<br>
The highest useable index of the array. This is `Size - 1`. Included simply for convenience.

`MemoryUsed: UINT32` **READ ONLY**<br>
The amount of memory in bytes of the useable portion of the array.

`MemoryReserved: UINT32` **READ ONLY**<br>
The total amount of memory in bytes reserved for the array.

`Empty: Boolean` **READ ONLY**<br>
Returns `TRUE` if `SIZE` is 0.
