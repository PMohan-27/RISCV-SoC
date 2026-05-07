import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


async def sdram_model(dut):
    while True:
        await RisingEdge(dut.clk)

        dut.instr_valid.value = 0
        dut.instr_last_beat.value = 0

        if dut.instr_ready.value == 1:
            base_address = int(dut.instr_addr.value)

            for beat_index in range(8):
                await RisingEdge(dut.clk)
                dut.instr_valid.value = 1
                dut.instr_data.value = base_address + beat_index

                if beat_index == 7:
                    dut.instr_last_beat.value = 1


async def reset(dut):
    dut.rst.value = 0
    for _ in range(5):
        await RisingEdge(dut.clk)
    dut.rst.value = 1
    for _ in range(5):
        await RisingEdge(dut.clk)


async def access(dut, address):
    dut.cpu_addr.value = address
    dut.cpu_ready.value = 1
    await RisingEdge(dut.clk)
    dut.cpu_ready.value = 0


@cocotb.test()
async def test_cache(dut):

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    cocotb.start_soon(sdram_model(dut))

    dut.cpu_addr.value = 0
    dut.cpu_ready.value = 0
    dut.instr_data.value = 0
    dut.instr_valid.value = 0
    dut.instr_last_beat.value = 0

    await reset(dut)

    addr1 = 0x1000
    await access(dut, addr1)

    for _ in range(50):
        await RisingEdge(dut.clk)

    dut.cpu_addr.value = addr1
    dut.cpu_ready.value = 1
    await RisingEdge(dut.clk)

    assert dut.cpu_valid.value == 1, "Expected HIT after cache fill"
    assert dut.cpu_data.value != 0, "Expected valid data on hit"
    dut.cpu_ready.value = 0

    addr2 = 0x2000
    await access(dut, addr2)

    for _ in range(50):
        await RisingEdge(dut.clk)

    dut.cpu_addr.value = addr2
    dut.cpu_ready.value = 1
    await RisingEdge(dut.clk)

    assert dut.cpu_valid.value == 1, "Expected HIT after second cache fill"
    assert dut.cpu_data.value != 0, "Expected valid data on second hit"
    dut.cpu_ready.value = 0