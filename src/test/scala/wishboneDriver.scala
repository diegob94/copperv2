package wishbone

import scala.language.implicitConversions
import chisel3._
import chiseltest._
import lithium.WishboneSource

class WishboneDriver(x: WishboneSource) {
  def setClock(clock: Clock): this.type = {
    ClockResolutionUtils.setClock(WishboneDriver.wishboneKey, x, clock)
    this
  }
  protected def getClock: Clock = {
    ClockResolutionUtils.getClock(
      WishboneDriver.wishboneKey,
      x,
      x.ack.getSourceClock
    ) // TODO: validate against bits/valid sink clocks
  }
  def waitForAck(): Unit = {
    while (x.ack.peek().litToBoolean == true) {
      getClock.step(1)
    }
  }
  def waitForCycleStart(): Unit = {
    while (x.stb.peek().litToBoolean == false | x.cyc.peek().litToBoolean == false) {
      getClock.step(1)
    }
  }
  def waitForStbNeg(): Unit = {
    while (x.stb.peek().litToBoolean == true) {
      getClock.step(1)
    }
  }
  def expectRead(addr: UInt, data: UInt): Unit = timescope {
    fork.withRegion(Monitor) {
        waitForCycleStart()
        x.stb.expect(true.B)
        x.cyc.expect(true.B)
        x.we.expect(false.B)
        x.adr.expect(addr)
        x.datrd.poke(data)
        x.ack.poke(true.B)
        waitForStbNeg()
        x.ack.poke(false.B)
      }
    .joinAndStep(getClock)
  }
  def expectWrite(): Unit = timescope {
    fork.withRegion(Monitor) {
        waitForAck()
        x.ack.expect(true.B)
        x.we.expect(true.B)
      }
    .joinAndStep(getClock)
  }
}
    //while True:
    //      await RisingEdge(self.clock)
    //      await ReadOnly()
    //      if self.in_reset:
    //          self.log.debug(f"WB sink receive in_reset true, continue...")
    //          continue
    //      if self.bus.ack.value.binstr == "1":
    //          received = dict(ack=True)
    //          if self.bus.we.value.binstr == "0":
    //              received['data'] = self.bus.datrd.value.integer
    //          yield received

object WishboneDriver {
  protected val wishboneKey = new Object()
}

package object conversions {
  implicit def toWishboneDriver(x: WishboneSource): WishboneDriver = new WishboneDriver(x)
}
