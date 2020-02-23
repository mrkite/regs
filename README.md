# What is this?

This is a set of command-line tools designed specifically to reverse engineer Apple IIgs software.  It is comprised of 2 separate tools; `2mg` and `regs`.  The first is a simple tool to extract disk images, the second is a more complicated tool that disassembles executables and allows you to query API information.

# 2mg

`2mg` extracts .2mg and .po prodos disk images.  When you give it a disk image filename, it will create a folder with the name of the disk, and extract all the files into that folder with the proper hierarchy.

You can also use it to list the contents of the disk image with the `-l` or `--list` command line argument.  Listing out the files will also give you the metadata associated with each file, such as creation date and file type.

# regs

`regs` is a combination of a couple of disassembly tools.  It can disassemble raw binary files, it can disassemble OMF files (like sys16 or tool files), and it can be used to inspect the Apple IIgs API.

Since it is a tracing disassembler, it will start disassembly at a given entrypoint and follow all possible paths.  Everything not disassembled will be assumed to be data and shown as a hex dump.

The first time `regs` is used to disassemble a specific file, it will create a `.regs` file with auto-detected information.

## regs commandline arguments

`regs` has a few flags that you can use to customize its disassembly.  If you are disassembling an OMF file, none of these flags do anything; the OMF file overrides this information.

These flags are really only useful for the initial disassembly.  Once a `.regs` file is created, you should use that to customize all future disassembly of that particular file.

For regular binary executables, you can specify where in memory they should be loaded with the `-o` or `--org` flag.  The passed address can be in decimal, or in hexadecimal if preceded with `$` or `0x`.  Be sure to wrap the argument in single-quotes if you use `$`, otherwise your shell will interpret it as a variable.  This address will also be used as the entrypoint of the executable.

You can force the disassembler to start in emulation mode with the `-e` flag. By default, the disassembler starts in native mode.  You can force the disassembler to use an 8-bit accumulator with '-m' and 8-bit indices with '-x'.  However, emulation mode assumes both of those flags already, just like on the actual hardware.

You'll notice there is also a `-l` flag, this is used for API queries, as described below.

## .regs files

As stated earlier, the first time you execute the disassembler, it creates a `.regs` file for that given executable.  The format of this file is fairly starightforward and lets you customize disassembly further.

Each line in this file starts with an address.  This address is of the format `$bank/offset` where both the dollar sign `$` and bank divider `/` are optional.

If the address is followed by an exclamation point `!`, it means this address is used as the point in memory the executable is loaded at.  (OMF files will ignore this). If more than one address is followed by an exclamation point, only the first address encountered will be used.

If the address is followed by a colon `:`, it means this address is considered an entrypoint.  Disassembly will start at this address.  There can be as many entrypoints as you wish.  In fact, as you disassemble a file, you may notice that disassembly is halted by indirect jumps.  You can add entrypoints to the `.regs` file to continue disassembly at the destination of those jumps.

After the colon, you can optionally specify "e" "m", "x" or any combination of those characters to force the disassembler state when disassembly starts at that entry point.

Finally, if the address is followed by a angle-bracket `<`, then this address has a symbolic name.  The symbolic name should be terminated with a closing angle-bracket `>`.  If an address has a symbolic name, this name will be used in place of the address whenever it appears in disassembly.

An address can be followed by any and all of the preceding markers.  For example, say you have an executable that is loaded at `$300`, which is also the entry point, and you want to start in emulation mode, and give the entrypoint a meaningful name.  This is a very common scenario and would result in a `.regs` file with a single line:

```
$300!:e<start>
```

Notice I left out the bank divider since it wasn't needed (the bank would naturally be 0), and also the 'm' and 'x' flags are always on in emulation mode, so I didn't need to include them.

The `.regs` file is actually rewritten every time you run the disassembler, so the format will be standardized and addresses will be sorted automatically for you.

## Workflow

Since it may not be obvious if you're used to other disassemblers, the workflow for this disassembler is of constant iteration.  You run the disassembler on an executable, then tweak the `.regs` file to add entrypoints as necessary, and add symbols to memory addresses as you identify their purpose.  Then re-run the disassembler each time.  The end result is a disassembly that gets cleaner and clearer and easier to follow.

## Disassembly notation

There are few things to note about the disassembly style of `regs`.  The first is that since we traced the code flow, branch destinations are preceded by a line that shows up to 7 source addresses and whether they are above or below the current line.  This will help you figure out code flow.

Next is that tool calls like `NewHandle` are shown as instructions.  This helps dramatically clean up the disassembly. Instead of showing the code that loads X with the tool number and then jumping to the tool dispatch address, we replace it all with just the name of the tool called.  This is controlled by the fingerprints in the iigs folder, described below.

Finally, and most unusual, I include "B:" and "D:" flags when the addressing uses DBR and Direct modes.  This is because the IIgs can change the direct page and DBR register and thus those addresses cannot be depended to be accurate.

If an address starts with "B:", then the current value of the DBR register should be added to the address.  If an address starts with "D:", then the current value of the Direct register should be added to the address.

Since they might be misleading, I also do not do symbol swapping on those addresses.  Instead any matching symbols are included as a comment on the same line.  That way if the IIgs is in a standard setup, then you know what those addresses represent, and if not, you can ignore the comment.

# Docmaker, the API, and the iigs folder

You'll notice a iigs folder that contains a bunch of text files that contain structures and function definitions related to the Apple IIgs API.  These files are parsed and compiled into the `regs` program for two purposes.

One, the functions have fingerprints attached to them that the disassembler can use to identify when the program is calling those functions and replace the system calls with actual function names.

Two, you can query `regs` for any given structure or function and even have it calculate field offsets for you.  This will help with disassembly.

Docmaker is the program that will read in the entire directory and generate a data file, which will get included when you compile `regs`.

## Querying the API

Querying the API is fairly simple, call `regs` with the `-l` flag, followed by a keyword.  No need to provide a file to disassemble when the `-l` flag is included.  Regs will then search the API for a data type or function that contains that keyword and output information about it.

If you're querying a structure, you can also use the `-o` or `--org` flag to specify where in ram that structure should start, and it will include the calculated offsets for each field.

For example, say the program you're disassembling calls `FrameRgn` and passes the value `$2/43a9` to the function.  You can do the following:

```
$ regs -l framergn
FrameRgn: (
  aRgnHandle: RgnHandle,
)
```

This lets you know that it takes a single argument which is of type `RgnHandle`.  You can query on `RgnHandle` and find out it's a double pointer to `Region`.  Next you can do:

```
$ regs -l region -o '$2/43a9'
Region: struct { // $a bytes
  rgnSize: int16 // $02/43a9
  rgnBBox: Rect // $02/43ab
  data: int16[] // $02/43b3
}
```

Now you know exactly what the variables at those memory addresses are and that might help with disassembly further down the line.  You might even want to add the fields back as symbols in the `.regs` file for future disassembly.


# Examples

The flexibility of these tools makes their use a little complicated.  So here are some examples of how to go about disassembling various things.

## Disassembling an S16

I'll use the S16 from Dream Zone as an example.  Generate an initial map and first disassembly:

`$ regs dream.sys16`

This will create a dream.sys16.regs file with an (unused) org address of `$00/0000`, and an entry point of `$01/0000`.  It will also create 5 files from `seg1` to `seg5`, this is the disassembly for each segment in the S16.

Looking at the seg1 disassembly, we notice that after calling a tool like `MMStartUp` or `NewHandle` the accumulator is stored at `$01/e4d0`.  I know from experience that this is the toolErr variable.  So let's add a symbol for it so we know what's happening if the code inspects it later.  Edit the dream.sys16.regs and add a line:

```
$01/e4d0<toolErr>
```

Rerun `regs` and now the disassembly properly references toolErr!

In a real project, you'll be adding hundreds or thousands of symbols.  The tools are designed for that.


### Disassembling a Tool

This works the same as disassembling an S16, but with an important difference.

We want to start without any entry points.  You can accomplish this by creating
an empty `.regs` file.  Then run regs on the tool file.

```
$ touch TOOL025.regs
$ regs TOOL025
```

Without any entrypoints, the entire file is just a hex dump.  However, it's a hex dump of the segment content, so it is missing all of the overhead and format information found in an OMF.  Thats why you can't just hex dump the original tool file for this.

All tools start with a tool table.  The first dword specifies the number of tools in this file.  The next dwords contain return addresses of the various tool entry points.

Let's say I want to disassemble `NoteOn`.  Running `regs -l noteon` shows me that it's tool $0b inside the $19 toolset.  Convert that to decimal to discover that's inside the TOOL025 file (the same file we already started using, how convenient). We can calculate the offset to tool $0b.

`$0b * 4 + $1/0000 = $1/002c`

We added `$1/0000` since that's where the toolset is disassembled, which we know from inspecting `seg1`.  Back to `seg1` at that offset, we see "99 02 01 00" which is little endian for the address `$1/299`.  Since these are return addresses, we need to increment that to get the actual entry point of `NoteOn`.

Add that entrypoint to the `.regs` file.

```
$00/0000!
$01/029a:
```

and rerun regs.  Re-check seg1, and down at `$01/29a` we have the disassembly for the `NoteOn` function, awesome!


### Disassembling a Specific Tool Call in ROM

Let's say I want to disassemble WriteRamBlock.  `regs -l writeramblock` shows us that it's tool 9 in toolset 8.  If you search, you'll discover that there isn't a TOOL008 anywhere because it's a toolset that's never been patched.  Instead we'll need to disassemble it directly from ROM.  I'll be using the 128k ROM01 just because I'm more familiar with it.  You can use ROM00 or ROM03 instead, it's just the locations of things will be different.

First thing I do, is actually handmake a `.regs` file for the ROM.

```
$fe/0000!:
```

Because that's where a 128k ROM should be loaded into memory, and I happen to know that the tool bootstrap is also located at that address.  For ROM03, you'll want to load the ROM into `$fc/0000`.  The tool bootstrap initializes the dispatches in bank `$e1`.  We see that code copies 16 bytes from `$fe/0051` to `$e1/0000`, which is the main tool dispatch. Let's add that entrypoint and disassemble again:

```
$fe/0051:
```

Stepping through this dispatch code, we see it first looks up your toolset from a table at `$fe/012f`.  Since we're after toolset $08, we calculate the offset: `$08 * 4 + $fe/012f = $fe/014f`.  We see at that location "00 3e ff 00" which is the little-endian representation of the address `$ff/3e00`.

The dispatch code then uses another table at that address to determine the return address of the entry point of the tool you want.  Since WriteRamBlock is tool 9, we calculate the offset into the new table: `$08 * 4 + $ff/3e00 = $ff/3e24`.

At that location is the value "a4 41 ff 00" which becomes `$ff/41a4` but since it's a return address, we should increment it before disassembling.

```
$ff/41a5:
```

Boom, we have just disassembled a specific tool call found in rom.


### Disassembling a simple ProDOS executable

ProDOS binaries aren't relocatable and don't have anything inside them that specifies where in RAM they should be loaded.  However, the filesystem itself does have that information.

Using `2mg` with the `-l` or `--list` argument will give a list of the files along with metadata associated with the files.  Let's use `BASIC.SYSTEM` as an example.

You'll see that `BASIC.SYSTEM` has a type of `$ff` and auxtype of `$2000`, and `2mg` identifies it as a "sys/ProDOS System File".  This is indeed a simple executable.

The aux type specifies where in RAM to load this executable.  In this case, it's `$2000`.

It is also important to note that these executables should start disassembly in emulation mode, since they're actually 8-bit executables.

We can use all of that information to disassemble this file.

`$ regs --org=0x2000 -e BASIC.SYSTEM`

This tells regs to start in emulation mode with 8-bit accumulator and indices, and load the file starting at `$2000` before disassembling it.

Since it's not an OMF file, there will be only 1 output file, `seg1`.  Note, however, that we still have a `BASIC.SYSTEM.regs` file so we can add symbols and alternative entrypoints if we wish (remember to include the 'e' flag on any alternative entrypoints, since regs defaults to native mode unless told otherwise).

The next time we want to disassemble this file, we don't have to pass any arguments since the flags and org are set properly in the `.regs` file.
