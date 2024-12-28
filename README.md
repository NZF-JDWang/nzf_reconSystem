# NZF Recon System

A modular reconnaissance and photography system for Arma 3 that allows mission makers to designate objects, vehicles, and personnel as photo targets with varying difficulty levels.

## Features

- Designate any object, vehicle, or person as a photo target
- Four difficulty levels for photo requirements
- Trigger-based system for mission events
- Configurable cleanup prevention for targets
- Debug mode for mission creation
- Compatible with multiplayer and dedicated servers

## Requirements

- Arma 3
- CBA_A3
- ACE3

## Usage

### Setting Up Targets

1. Place the "NZF Set Recon Target" module (found under NZF Systems)
2. Sync the module to your target object
3. Configure the module settings:
   - Photo Requirements: Sets how difficult it is to photograph the target
   - Prevent Cleanup: Keeps the target from being removed by cleanup scripts in case you want to photograph dead bodies

### Photo Requirements

Four difficulty levels are available:

1. **Easy** (40% threshold)
   - Target just needs to be visible in frame
   - Minimal framing requirements

2. **Medium** (100% threshold)
   - Target needs to be clearly visible
   - Standard framing requirements

3. **Hard** (200% threshold)
   - Target needs to be clearly visible and well-framed
   - Requires closer range or better angles

4. **Extra Hard** (600% threshold)
   - For documents and items requiring extreme detail
   - Requires perfect framing and very close range

### Target Types

Different target types have different base requirements:
- Personnel: 1000 base value
- Vehicles: 8000 base value
- Other Objects: 1000 base value

### Trigger System

The module can be synced with triggers that activate when a valid photo is taken. This allows for:
- Mission objectives
- Custom events
- Scripted sequences
- Scoring systems

## Debug Mode

Enable debug mode to see:
- Target validation information
- Screen coverage details
- Photo requirement calculations
- Target registration status

## Credits

Author: [NZF] JD Wang
New Zealand Forces

## Version

0.1 - Initial Release 