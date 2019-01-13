### zokrates notes
https://zokrates.github.io/sha256example.html#computing-a-hash-using-zokrates
A field value can only hold 254 bits due to the size of the underlying prime field used by zokrates. Therefore, 256 bit values need to be passed as 2 params of 128 bit values.

https://zokrates.github.io/concepts/stdlib.html?highlight=sha256#sha256packed
At the time of writing sha256packed takes 4 field elements as inputs, unpacks each of them to 128 bits (big endian), concatenates them and applies sha256. It then returns two field elements, each representing 128 bits of the result.