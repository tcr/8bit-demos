--This is an example script to give a general idea of how to build scripts
--Press F5 or click the Run button to execute it
--Scripts must be written in Lua (https://www.lua.org)
--This text editor contains an auto-complete feature for all Mesen-specific functions
--Typing "emu." will display a list containing every available API function to interact with Mesen

nextFrame = False
frameCount = nil
ppuCycle = nil
scanline = nil
offset = nil

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

    if ppuCycle < 338 and scanline == 240 then
      print(ppuCycle)
      emu.breakExecution()
      end
  end
    
  if frameCount ~= nil then
    --Draw some rectangles and print some text
    emu.drawRectangle(8, 8, 128, 36, bgColor, true, 1)
    emu.drawRectangle(8, 8, 128, 36, fgColor, false, 1)
    emu.drawString(12, 12, "Offset: $" .. string.format("%x", offset), 0xFFFFFF, 0xFF000000, 1)
    emu.drawString(12, 21, "PPU Cycle: " .. ppuCycle, 0xFFFFFF, 0xFF000000, 1)
    emu.drawString(12, 30, "Scanline: " .. scanline, 0xFFFFFF, 0xFF000000, 1)
  end
end

--Register some code (printInfo function) that will be run at the end of each frame
emu.addEventCallback(printInfo, emu.eventType.irq)

function clearInfo()
  nextFrame = false
  frameCount = nil
  end

emu.addMemoryCallback(clearInfo, emu.memCallbackType.cpuExec, 0x8000, 0x8004)

--Display a startup message
emu.displayMessage("Script", "Example Lua script loaded.")
