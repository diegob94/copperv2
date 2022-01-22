package lithium

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

import wishbone.conversions._

class BasicTest extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WishboneAdapter"
  it should "read" in {
    test(new WishboneAdapter(4,4,1)).withAnnotations(Seq(WriteVcdAnnotation)) { c =>
      val addr = 1.U;
      val data = 2.U;
      c.bus.r.addr.initSource().setSourceClock(c.clock)
      c.bus.r.data.initSink().setSinkClock(c.clock)
      c.wb.setClock(c.clock)
      c.bus.r.addr.enqueue(addr)
      c.wb.expectRead(addr,data)
      c.bus.r.data.expectDequeueNow(data)
    }
  }
}