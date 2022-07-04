-- Keep hitting inputs and triggering reset until we get an incorrect sync,
-- then break.

nextFrame = False
frameCount = nil
ppuCycle = nil
scanline = nil
offset = nil

randomInputEnabled = true
randomInputCount = 0

function printInfo()
  --Get the emulation state
  state = emu.getState()

  bgColor = 0x302060FF
  fgColor = 0x30FF4040
  
  if emu.read(0, emu.memType.cpu) == 0x4c then
    nextFrame = true
    offset = emu.read(0x100 + state.cpu.sp + 2, emu.memType.cpu)
  elseif nextFrame then
    nextFrame = false
    frameCount = state.ppu.frameCount
    ppuCycle = state.ppu.cycle
    scanline = state.ppu.scanline
      randomInputCount = randomInputCount + 1

    --Draw some rectangles and print some text
    emu.drawRectangle(8, 8, 128, 36, bgColor, true, 0)
    emu.drawRectangle(8, 8, 128, 36, fgColor, false, 0)
    emu.drawString(12, 12, "Offset: $" .. string.format("%02x", offset), 0xFFFFFF, 0xFF000000, 0)
    emu.drawString(12, 21, "PPU Cycle: " .. ppuCycle, 0xFFFFFF, 0xFF000000, 0)
    emu.drawString(12, 30, "Scanline: " .. scanline, 0xFFFFFF, 0xFF000000, 0)
    emu.drawString(100, 30, "#" .. randomInputCount, 0xFFFFFF, 0xFF000000, 0)

    if ppuCycle ~= 338 and ppuCycle ~= 339 then
      print(ppuCycle)
      emu.breakExecution()
      randomInputEnabled = false
      emu.displayMessage('frameCount', frameCount)
      emu.displayMessage('ppuCycle', ppuCycle)
      emu.displayMessage('offset', offset)
    end
  end
    
  if frameCount ~= nil then
    --Draw some rectangles and print some text
    emu.drawRectangle(8, 8, 128, 36, bgColor, true, 1)
    emu.drawRectangle(8, 8, 128, 36, fgColor, false, 1)
    emu.drawString(12, 12, "Offset: $" .. string.format("%x", offset), 0xFFFFFF, 0xFF000000, 1)
    emu.drawString(12, 21, "PPU Cycle: " .. ppuCycle, 0xFFFFFF, 0xFF000000, 1)
    emu.drawString(12, 30, "Scanline: " .. scanline, 0xFFFFFF, 0xFF000000, 1)
    emu.drawString(100, 30, "#" .. randomInputCount, 0xFFFFFF, 0xFF000000, 0)

  end
end

--Register some code (printInfo function) that will be run at the end of each frame
emu.addEventCallback(printInfo, emu.eventType.irq)

function clearInfo()
  nextFrame = false
  frameCount = nil
  end

emu.addMemoryCallback(clearInfo, emu.memCallbackType.cpuExec, 0x8000, 0x8004)

function randomInput()
  if not randomInputEnabled then return end
  
  if math.random() < 0.003 then
    emu.reset()
    end
  
  emu.setInput(0, {a = math.random() < 0.1, b = math.random() < 0.9, left = math.random() < 0.1, right = math.random() < 0.1})
  end

-- Comment this out if you just need the overlay.
emu.addEventCallback(randomInput, emu.eventType.inputPolled)

--Display a startup message
emu.displayMessage("Script", "DMC Sync script loaded.")
