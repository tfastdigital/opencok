# OpenCoK Building Alignment Fixes

1. **Level Badge Overlay (`CastleViewport`)**: Wrapped `AnimatedBuilder` in `Positioned.fill` so building level badges (`30`, `22`, `20`, `18`, etc.) render and track camera pan/zoom reliably.
2. **Citadel & Civic Pads**: Replaced placeholder world-map castle sprite with extracted Clash of Kings `castle.png` (`783x729`), `watchtower.png`, `academy.png`, `embassy.png`, `hall_of_war.png`, `warehouse.png`, `market.png`, `forge.png`, and `hospital.png`, aligned onto their exact circular stone pads via `east_courtyard_check.png` and verified on `SM_A165F` (`east_final.png`).
3. **Production Plots**: Placed `farm.png`, `sawmill.png`, `iron_mine.png`, `mithril_mine.png`, and 6 interactive `+ Build` outer resource plots on the eastern plateau and clearings (`verify_5_outer_farms.png`).
4. **Dev Layout Debug Overlay**: Added `CityLayoutDebugOverlay` (`!kReleaseMode` toggle button in `CastleViewport`) showing slot bounds, slot IDs, render layers, centers, and empty resource plots.
