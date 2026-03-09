import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def test(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    await RisingEdge(dut.clk)
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0