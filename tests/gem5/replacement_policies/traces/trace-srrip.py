from m5.objects.ReplacementPolicies import RRIPRP as rp

# define the traffic generator pattern
def python_generator(generator):
    # Access 1 (Block 0x0)
    yield generator.createLinear(60000, 0x0, 0x3F, 64, 30000, 30000, 100, 0)
    # Access 2 (Block 0x80)
    yield generator.createLinear(60000, 0x80, 0xBF, 64, 30000, 30000, 100, 0)
    # Access 3 (Block 0x100)
    yield generator.createLinear(60000, 0x100, 0x13F, 64, 30000, 30000, 100, 0)
    # Access 4 (Block 0x180)
    yield generator.createLinear(60000, 0x180, 0x1BF, 64, 30000, 30000, 100, 0)
    # Access 5 (Block 0x0) - REPEAT
    yield generator.createLinear(60000, 0x0, 0x3F, 64, 30000, 30000, 100, 0)
    # Access 6 (Block 0x200)
    yield generator.createLinear(60000, 0x200, 0x23F, 64, 30000, 30000, 100, 0)
    # Access 7 (Block 0x180) - REPEAT
    yield generator.createLinear(60000, 0x180, 0x1BF, 64, 30000, 30000, 100, 0)
    # Access 8 (Block 0x100) - REPEAT
    yield generator.createLinear(60000, 0x100, 0x13F, 64, 30000, 30000, 100, 0)
    # Access 9 (Block 0x380)
    yield generator.createLinear(60000, 0x380, 0x3BF, 64, 30000, 30000, 100, 0)
    # Access 10 (Block 0x0) - REPEAT
    yield generator.createLinear(60000, 0x0, 0x3F, 64, 30000, 30000, 100, 0)

    # After all memory accesses, synchronize
    yield generator.createLinear(30000, 0, 0, 0, 30000, 30000, 100, 0)
 
    # Tell the traffic generator to exit
    yield generator.createExit(0)