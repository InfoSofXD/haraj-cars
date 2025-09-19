# Worker Authentication Usage Examples

## 🔐 **Name-Based Authentication**

Now you can login workers using either their **name** or **phone number** with password!

### **Method 1: Using the Worker Login Screen**

1. **Go to Role Selection** → Choose **"Worker"**
2. **Toggle Login Mode**:
   - Switch to **"Login with Name"** mode
   - Enter worker name: `Test Worker`
   - Enter password: `123456`
3. **Click Sign In**

### **Method 2: Using Code**

```dart
final authService = WorkerAuthService();

// Login with name
final result = await authService.signInWithName(
  name: 'Test Worker',
  password: '123456',
);

// Login with phone
final result2 = await authService.signIn(
  phone: '+1234567890',
  password: '123456',
);

// Flexible login (tries phone first, then name)
final result3 = await authService.signInFlexible(
  identifier: 'Test Worker', // or '+1234567890'
  password: '123456',
);
```

## 🧪 **Testing Authentication**

### **Using Debug Helper**

```dart
// Test name authentication
await WorkerDebugHelper.testWorkerAuthByName('Test Worker', '123456');

// Test phone authentication  
await WorkerDebugHelper.testWorkerAuth('+1234567890', '123456');
```

### **Using Debug Screen**

1. Go to **Role Selection** → **"Worker Debug Helper"**
2. Click **"Create Test Worker"** to add test data
3. Click **"Test Auth"** to verify both methods work

## 📱 **Available Test Credentials**

After running the SQL script or debug helper, you can login with:

| Method | Identifier | Password |
|--------|------------|----------|
| **Name** | `Test Worker` | `123456` |
| **Phone** | `+1234567890` | `123456` |
| **Name** | `John Smith` | `123456` |
| **Phone** | `+1234567891` | `123456` |
| **Name** | `Sarah Johnson` | `123456` |
| **Phone** | `+1234567892` | `123456` |

## 🔄 **How It Works**

The system now supports **3 authentication methods**:

1. **Phone + Password**: Traditional phone-based login
2. **Name + Password**: New name-based login  
3. **Flexible**: Automatically detects if input is phone or name

### **Flexible Authentication Logic**

```dart
// If identifier starts with '+' or contains only digits → try phone
if (identifier.startsWith('+') || RegExp(r'^\d+$').hasMatch(identifier)) {
  // Try phone authentication
}

// Otherwise → try name authentication
// Try name authentication
```

## 🚀 **Quick Start**

1. **Create Test Workers**: Use debug helper or SQL script
2. **Try Name Login**: Use "Test Worker" + "123456"
3. **Try Phone Login**: Use "+1234567890" + "123456"
4. **Both should work!** ✅

## 🔧 **Debugging**

If authentication fails, check the console logs:

```
🔐 Attempting to authenticate worker with name: Test Worker
👤 Found 1 workers with name: Test Worker
✅ Worker authenticated successfully by name
```

Or for phone:

```
🔐 Attempting to authenticate worker with phone: +1234567890
📱 Found 1 workers with phone: +1234567890
✅ Worker authenticated successfully
```
