# Aimlab

A FiveM aim trainer with multiple gamemodes and a UI written in Svelte.

TP into a training area and practice your aim against configurable target patterns, basically a mini aimlab built for FiveM.

This was one of my first Svelte projects, so the UI doubled as a way to actually learn the framework.

## Features

- Multiple gamemodes (tracking mode, plus a more erratic "wander" variant)
- Configurable distance, speed, tolerance, and fill/decay rates
- Progress meter that fills while on target and decays when you lose it
- Svelte NUI overlay showing live progress
- Works across ESX, QBCore, and QBox (is not dependant on any framework)
- Restores your position and weapon when a session ends

## Dependencies

[ox_lib](https://github.com/overextended/ox_lib)
[oxmysql](https://github.com/overextended/oxmysql)

## How it works

A session starts, your position gets saved, and you're teleported to the training spot with a target spawned in front of you. The target moves depending on the gamemode. Every frame, its screen position is checked against your crosshair, if you're within tolerance the progress meter fills, otherwise it decays. Filling the meter counts as a hit and the UI updates live. When the session ends, the target despawns and you're put back where you started.

## Showcase

<table>
  <tr>
    <td width="50%">
      <img src="https://raw.githubusercontent.com/Zykem/zkm-aimlab/main/showcases/fhd_ui_preview.PNG" alt="FHD UI Preview" width="100%">
    </td>
    <td width="50%">
      <video src="https://raw.githubusercontent.com/Zykem/zkm-aimlab/main/showcases/script_showcase.mp4" controls width="100%"></video>
    </td>
  </tr>
</table>

## Status

Ready-to-use script, with potential updates in the future.
