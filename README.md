# Bus Booking App - Full Stack

This repository now contains two apps:
- `backend`: Node.js + Express + MySQL + Sequelize + JWT + Razorpay test stub
- `frontend`: React + Tailwind UI + JWT token login

## Backend Setup
1. `cd backend`
2. `npm install`
3. rename `.env.sample` to `.env` and set your DB + JWT + Razorpay keys
4. `npm run seed` (creates admin/operator/test user + sample routes/buses)
5. `npm start` or `npm run dev`

## Frontend Setup
1. `cd frontend`
2. `npm install`
3. `npm start`

## Test accounts
- admin@busapp.com / Admin@123
- operator@busapp.com / Operator@123
- user@busapp.com / User@1234

## API List
- POST `/api/auth/register`
- POST `/api/auth/login`
- GET `/api/buses` (auth)
- GET `/api/buses/:id` (auth)
- POST `/api/bookings/create` (auth)
- GET `/api/bookings` (auth)
- POST `/api/bookings/:id/cancel` (auth)
- GET `/api/admin/analytics` (admin)
- POST `/api/admin/buses` (admin)
- POST `/api/operator/buses` (operator)

## Notes
- This is a complete MVP with full role-based architecture.
- Razorpay creates test orders; for production, use webhook & signature verification.
- Booking seat locking is done through seat count and seat availability adjustments.
- Use migration and deeper validation in production code.
