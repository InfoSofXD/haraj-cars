# Haraj Cars - Flutter App

A Flutter application for browsing and managing car listings using Supabase as the backend.

## Features

- **Car Listings**: Browse cars with title, price, photo, and description
- **Search & Filter**: Search by title/description and filter by price range
- **Contact Integration**: Direct contact buttons for WhatsApp, phone, and email
- **Admin Panel**: Hidden admin login for managing cars (add, edit, delete)
- **Online Only**: Requires internet connection to function
- **Responsive Design**: Works on mobile and web platforms

## Prerequisites

- Flutter SDK (>=3.1.5)
- Dart SDK (>=3.1.5)
- Supabase account and project
- Android Studio / VS Code

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd haraj_cars
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Supabase Setup

1. **Create a Supabase Project**:
   - Go to [supabase.com](https://supabase.com)
   - Create a new project
   - Note down your project URL and anon key

2. **Update Configuration**:
   - Open `lib/supabase/supabase_config.dart`
   - Replace the URL and anon key with your project credentials

3. **Run Database Schema**:
   - Go to your Supabase project dashboard
   - Navigate to SQL Editor
   - Copy and paste the contents of `lib/supabase/sql/schema.sql`
   - Execute the SQL commands

4. **Create Storage Bucket**:
   - In Supabase dashboard, go to Storage
   - Create a new bucket called `car-images`
   - Set it to public

### 4. Run the App

```bash
flutter run
```

## Default Admin Credentials

- **Username**: `admin`
- **Password**: `admin123`

**Important**: Change these credentials in production!

## App Structure

```
lib/
├── haraj/
│   ├── models/
│   │   └── car.dart              # Car data model
│   ├── services/
│   │   └── supabase_service.dart # Database operations
│   └── widgets/
│       ├── car_card.dart         # Individual car display
│       ├── add_edit_car_dialog.dart # Add/edit car form
│       ├── admin_login_dialog.dart   # Admin authentication
│       └── home_page.dart        # Main app screen
├── supabase/
│   ├── sql/
│   │   └── schema.sql            # Database schema
│   └── supabase_config.dart      # Supabase configuration
├── tools/
│   └── connectivity.dart         # Internet connectivity check
└── main.dart                     # App entry point
```

## Database Schema

### Cars Table
- `id`: Primary key
- `car_id`: Unique UUID for each car
- `title`: Car title/name
- `description`: Car description
- `price`: Car price (decimal)
- `main_image`: Main car image URL
- `other_images`: Array of additional image URLs
- `contact`: Contact information
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

### Admin Table
- `id`: Primary key
- `username`: Admin username
- `password`: Admin password
- `created_at`: Creation timestamp

## Usage

### For Users (Guests)
1. Browse car listings on the main page
2. Use search bar to find specific cars
3. Adjust price range filter
4. Tap contact button to reach seller

### For Admins
1. **Access Admin Panel**: Tap the admin icon in the app bar
2. **Login**: Use admin credentials
3. **Add Car**: Tap the floating action button (+)
4. **Edit Car**: Tap edit icon on any car card
5. **Delete Car**: Tap delete icon on any car card

## Features

- **Search**: Real-time search by title or description
- **Price Filter**: Slider to filter cars by price range
- **Image Upload**: Support for car photos
- **Contact Integration**: Direct links to phone, WhatsApp, email
- **Responsive UI**: Works on all screen sizes
- **Offline Detection**: Shows offline message when no internet

## Dependencies

- `supabase_flutter`: Backend database and storage
- `connectivity_plus`: Internet connectivity checking
- `image_picker`: Image selection from gallery/camera
- `url_launcher`: Opening contact links
- `uuid`: Generating unique identifiers
- `intl`: Number formatting

## Troubleshooting

### Common Issues

1. **Supabase Connection Error**:
   - Check your internet connection
   - Verify Supabase URL and anon key
   - Ensure Supabase project is active

2. **Image Upload Fails**:
   - Check storage bucket permissions
   - Verify bucket name is `car-images`
   - Ensure bucket is public

3. **Admin Login Fails**:
   - Verify admin table exists
   - Check default credentials
   - Ensure RLS policies are correct

### Performance Tips

- Images are automatically compressed before upload
- Search uses database indexes for fast results
- Price filtering is optimized with database queries

## Security Notes

- Admin credentials are stored in plain text (change for production)
- Row Level Security (RLS) is enabled on all tables
- Public read access, authenticated write access
- Consider implementing proper authentication for production

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions, please open an issue in the repository.
