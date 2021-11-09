# Gameboy Color Illegal Speed Switch Tests
This is a collection of illegal speed switch tests I made a few months back for the Gameboy Color, which I made partly for hardware research, and partly to prove LIJI32 is kind of nuts\.
Since I made them mostly for internal use, rebuilding them from the assembly source code should be accessible enough for experienced Gameboy assembly programmers\.

---

### What the heck is an illegal speed switch?
LIJI32 did some testing with switching the speed on a Gameboy Color in certain situations, and apparently nailed down a scenario where the system could theoretically glitch out unpredictably
\. I replicated those scenarios with at least some of these ROMs, but still could not get the glitching to happen\. Instead, it led to some findings that are dependent on which revision of CPU they are ran on\- with more specifically, at least from what I can recall, the 6th illegal speed switch test\.
The "illegal" speed switch in question is performed by setting bit 7 of the speed switch register, setting the interrupt flags and the interrupt enable register, and then executing the CPU's interrupt enable opcode \(which is `ei`\) right before executing a STOP\. This causes an interrupt to fire at the exact moment the CPU is supposed to switch speeds, which according to LIJI would cause the system to glitch out because of the conflicting internal states, but instead just causes the system to fail to perform a speed switch\. It also does a few other things\.\.\.

---

### What does it do?
The end behavior depends on the revision of CGB CPU, and whether it's ran on a Gameboy Advance\. Here are the specific differences:
- On CGB revisions 0, A, B and C, nothing special happens, and the end value of the divider register \(`DIV`\) is always 0
- On CGB revisions D and E, and on AGB, the end value of `DIV` is randomly either 0 or 1
- On AGB only, any of the bottom 4 bits of flags can be set, despite them not being used in the CPU

Your guess is as good as mine as to why those 4 bits get set\. Perhaps you'd like to find out?