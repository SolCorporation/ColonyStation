###### Special thanks to [HippieStation](https://github.com/HippieStation/HippieStation/blob/master/hippiestation/README.md) for the help.

# Why do we use this /colony/ folder?

The way Github works, is that changes to the codebase are marked by the addition, deletion, or editing of particular lines in the code files, or whatever. "This PR adds these lines, edits this line, and removes some of these lines," that sort of deal.

However, if /TG/ edits a line that we ourselves have edited, Github does not know which edit to use. This produces a **Merge Conflict**, where an actual person must manually inform Github on what to do. This is annoying and prone to human error.

So to keep up-to-date with /tg/station while trying to avoid merge conflicts as much as possible, we modularize everything. This is the same method [HippieStation](https://github.com/HippieStation/HippieStation/tree/master/hippiestation) uses. Making code not have to edit large swaths of the original /TG/ code files means fewer conflicts and less headcoders banging their heads on their desks over your crap PR.

## What does it mean to modularize something?

Something is modular when it exists independent from the rest of the code, or at least absolutely minimizes dependency. This means that by simply adding something modular to the DME file, it will exist in-game. It is not always possible to completely modularize something, but if standards are followed correctly, then there should be few to none conflicts with /tg/station in the future.

## How do I be "modular?"

All modifications to non-CS files should be marked.

- Multi line changes start with `// colony start` and end with `// colony end`
- You should put a message with a change if it isn't obvious, like this: `// colony start - reason`
  - Should generally be about the reason the change was made, what it was before, or what the change is
  - Multi-line messages should start with `// colony start` and use `/* Multi line message here */` for the message itself
- Single line changes should have `// colony` or `// colony - reason`

If you need to mirror a file or function into a CS-specific file, please leave behind a comment stating where it went.

```
// colony start - Mirrored this function in <file> for <reason>
bunch of shitcode here
// colony end
```

Once you mirror a file, please follow the above for marking your changes, this way we know what needs to be updated when a file has been mirrored.


### tgstation.dme versus colonystation.dme

**Do not alter the tgstation.dme file.** All additions and removals should be to the colonystation.dme file. Do not manually add files to the dme! Check the file's box in the Dream Maker program. The Dream Maker does not always use alphabetical order, and manually adding a file can cause it to reorder. This means that down the line, many PRs will contain this reorder when it could have been avoided in the first place.

### Icons, code, and sounds

Icons are notorious for conflicts. Because of this, **ALL NEW ICONS** must go in the "colony/icons" folder. There are to be no exceptions to this rule. Sounds don't cause conflicts, but for the sake of organization they are to go in the "colony/sounds" folder. No exceptions, either. Unless absolutely necessary, code should go in the "colony/code" folder. Small changes outside of the folder should be done with hook-procs. Larger changes should simply mirror the file in the "colony/code" folder.

### Defines

Defines only work if they come before the code in which they are used. Because of this, please put all defines in the ``code/__DEFINES/~colony_defines`` path. Use an existing file, or create a new one if necessary.

If a small addition needs to be made outside of the "colony" folder, then it should be done by adding a proc. This proc will be defined inside of the "colony" folder. By doing this, a large number of things can be done by adding just one line of code outside of the folder! If a file must be changed a lot, re-create it with the changes inside of the "colony/code" folder. **Make sure to follow the file's path correctly** (i.e. "code/modules/clothing/clothing.dm"). Then, remove the original file from the colonystation.dme and add the new one.

## Can you give some examples?

### Clothing

New clothing items should be a subtype of ``/obj/item/clothing/CLOTHINGTYPE/yogs`` inside of the respective clothing file. For example, replace CLOTHINGTYPE with ears to get ``/obj/item/clothing/ears/yogs`` inside of "ears.dm" in "code/modules/clothing." If the file does not exist, create it and follow this format.

### Actions and spells

New actions and spells should use the "colony/icons/mob/actions.dmi" file. If it is a spell, put the code for the spell in "colony/code/modules/spells." To make sure that the spell uses the Yogs icon, please add ``action_icon = 'colony/icons/mob/actions.dmi'`` and the ``action_icon_state`` var.

### Reagents

New reagents should go inside "colony/code/modules/reagents/drug_reagents.dm." In this case, "drug_reagents" is an example, so please use or create a "toxins.dm" if you are adding a new toxin. Recipes should go inside "colony/code/modules/reagents/recipes/drug_reagents.dm."

---

### Thank you for following these rules! Please contact a maintainer or headcoder if you have any questions about modular code or the "colony" folder.
