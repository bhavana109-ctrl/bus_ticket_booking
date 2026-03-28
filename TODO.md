# Bus Cancellation Interior Preview TODO

## [ ] Step 1: Update app.py
- Add `booking['interior_gallery'] = build_bus_interior_gallery(booking)` after `derive_bus_preferences(booking)` in:
  * cancel_booking route (after fetching updated_booking)
  * cancellation_details route

## [ ] Step 2: Update templates/cancellation_details.html
- After "Cancelled Trip Details" detail-block, add "Bus Interior Preview" section:
  * Copy carousel markup from bus_details.html (id="interiorCarousel")
  * Use {{ booking.interior_gallery }}
  * Add inline styles for .interior-image, .interior-caption

## [ ] Step 3: Test
- python app.py
- Login → booking_history → Cancel booking → Verify page shows:
  * Existing bus info intact
  * **New working interior carousel with SVGs** (3 images)
  * Responsive/print-friendly

## [ ] Step 4: Complete
- attempt_completion

