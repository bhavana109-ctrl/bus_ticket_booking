// this script now only handles the seat map on the /select_seats page

function generateSeats() {
    const container = document.getElementById("seatsContainer"); // FIXED ID
    if (!container) return;

    container.innerHTML = "";

    const totalSeats = 40;

    // Safety fix
    if (!BOOKED_SEATS) BOOKED_SEATS = [];

    for (let i = 1; i <= totalSeats; i++) {
        const seat = document.createElement("div");
        const seatNum = i.toString(); // FIXED (no padStart)

        seat.innerText = seatNum;
        seat.classList.add("seat");

        if (BOOKED_SEATS.includes(seatNum)) {
            seat.classList.add("booked");
        } else {
            seat.classList.add("available");

            seat.addEventListener("click", () => {
                toggleSeat(seatNum, seat);
            });
        }

        container.appendChild(seat);
    }

    updateSelectedInput();
}

let selectedSeats = [];

function toggleSeat(seatNum, seatElement) {
    if (selectedSeats.includes(seatNum)) {
        // Deselect
        selectedSeats = selectedSeats.filter(seat => seat !== seatNum);
        seatElement.classList.remove("selected");
        seatElement.classList.add("available");
    } else {
        // Select
        selectedSeats.push(seatNum);
        seatElement.classList.remove("available");
        seatElement.classList.add("selected");
    }

    updateSelectedInput();
}

function updateSelectedInput() {
    const seatsInput = document.getElementById("selectedSeats");
    const seatsListInput = document.getElementById("seats_list");

    const info = document.getElementById("seatInfo");

    if (seatsInput) {
        seatsInput.value = selectedSeats.join(",");
    }

    if (seatsListInput) {
        seatsListInput.value = selectedSeats.join(","); // IMPORTANT FIX
    }

    if (info) {
        const count = selectedSeats.length;

        let status = `${count} seat(s) selected – ₹${count * BUS_PRICE}`;

        info.innerText = status;
    }

    // Enable / Disable button (if exists)
    const btn = document.getElementById("proceedBtn");
    if (btn) {
        btn.disabled = selectedSeats.length === 0;
    }
}

// Clear selection when needed
function updateSeatSelection() {
    selectedSeats = [];
    const seats = document.querySelectorAll(".seat.selected");

    seats.forEach(seat => {
        seat.classList.remove("selected");
        seat.classList.add("available");
    });

    updateSelectedInput();
}

// Initialize ONLY on select seats page
if (window.location.pathname.includes("/select_seats")) {
    document.addEventListener("DOMContentLoaded", generateSeats);
}