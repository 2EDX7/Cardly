# Offline/Online Synchronization Implementation

## Overview
This document describes the complete offline/online data synchronization system implemented for Cardly, ensuring seamless operation regardless of network connectivity.

## Architecture

### Core Components

#### 1. ConnectivityService (`lib/data/services/connectivity_service.dart`)
- **Purpose**: Monitor network connectivity in real-time
- **Features**:
  - Uses `connectivity_plus` package to detect network changes
  - Broadcasts connection status via Stream
  - Supports mobile, WiFi, and Ethernet connections
  - Provides async `checkConnection()` method

#### 2. SyncService (`lib/data/services/sync_service.dart`)
- **Purpose**: Coordinate bidirectional synchronization between SQLite and MongoDB
- **Features**:
  - Auto-syncs when connectivity is restored
  - Push local changes to backend
  - Pull backend updates to local database
  - Conflict resolution (backend wins if no local changes)
  - Status broadcasting (idle, syncing, success, error)

#### 3. HybridCardRepository (`lib/data/repositories/hybrid_card_repository.dart`)
- **Purpose**: Unified repository that decides between local and API operations
- **Features**:
  - All reads from local for fast access
  - All writes to local immediately
  - Attempts backend sync if online
  - Marks cards with `needsSync` flag when sync fails
  - Triggers background sync automatically

### Database Schema Updates

#### New Columns in `cards` Table (Version 3)
```sql
backendId TEXT           -- MongoDB document ID
shareableId TEXT         -- Shareable ID for QR codes
customCategory TEXT      -- User-defined custom categories
tags TEXT                -- Comma-separated tags
notes TEXT               -- User notes for the card
needsSync INTEGER        -- 1 if local changes not synced, 0 if synced
lastSyncedAt TEXT        -- ISO 8601 timestamp of last successful sync
```

### Data Model Updates

#### CardInfo Model (`lib/data/models/card_info.dart`)
New fields added:
```dart
bool needsSync;          // true if card has unsynced changes
DateTime? lastSyncedAt;  // Last successful sync timestamp
```

## Sync Flow

### 1. Adding a New Card
```
User creates card
    ↓
Save to SQLite (immediate)
    ↓
Mark needsSync = true
    ↓
If online:
    ↓
    Try sync to backend
    ↓
    Success? → Update backendId, needsSync = false
    ↓
    Failure? → Keep needsSync = true, will retry on reconnect
```

### 2. Editing an Existing Card
```
User edits card
    ↓
Update SQLite (immediate)
    ↓
Mark needsSync = true
    ↓
If online && has backendId:
    ↓
    Try update backend
    ↓
    Success? → needsSync = false, lastSyncedAt = now
    ↓
    Failure? → Keep needsSync = true
```

### 3. Deleting a Card
```
User deletes card
    ↓
Delete from SQLite (immediate)
    ↓
If online && has backendId:
    ↓
    Try delete from backend
    ↓
    Failure? → Log warning (card already removed locally)
```

### 4. Reconnection Sync
```
Network comes back online
    ↓
ConnectivityService detects change
    ↓
SyncService.syncAll() triggered automatically
    ↓
Push Phase:
    - Get all cards where needsSync = true
    - For each card:
        - Has backendId? → Update backend
        - No backendId? → Create on backend
    - Update local with backend IDs
    ↓
Pull Phase:
    - Fetch all cards from backend
    - For each backend card:
        - Compare lastSyncedAt timestamps
        - Backend newer? → Update local
        - Backend has cards not local? → Insert local
    ↓
Emit SyncStatus.success
```

## Conflict Resolution Strategy

### Scenario 1: Edit While Offline
- **Action**: Changes saved locally, marked `needsSync = true`
- **On Reconnect**: Local changes pushed to backend
- **Result**: Local changes preserved

### Scenario 2: Backend Updated by Another Device
- **Check**: Compare `lastSyncedAt` timestamps
- **Conflict**: Backend newer than local
- **Resolution**:
  - If `needsSync = false`: Backend wins (newer data)
  - If `needsSync = true`: Local wins (pending changes)

### Scenario 3: Delete Conflicts
- **Local Delete**: Card removed from SQLite, backend delete attempted
- **Backend Delete**: Detected during pull phase, local card removed
- **Result**: Deletions always propagate

## Implementation Status

### ✅ Completed
1. **Database Schema**: Added sync columns to cards table with migration
2. **Data Model**: Extended CardInfo with sync fields
3. **ConnectivityService**: Network monitoring with real-time status
4. **SyncService**: Complete bidirectional sync logic
5. **HybridCardRepository**: Unified local/API repository
6. **SQLiteCardRepository**: Updated to handle sync fields
7. **DatabaseHelper**: All methods updated to persist sync data

### ⏳ Pending Integration
1. **CardCubit Integration**:
   - Replace ApiCardRepository with HybridCardRepository
   - Initialize SyncService
   - Listen to sync status stream
   - Emit sync progress states

2. **UI Sync Indicators**:
   - App bar sync icon
   - "Syncing..." progress indicator
   - "Offline - changes will sync" message
   - Last sync timestamp display

3. **App Initialization**:
   - Create service instances
   - Pass to repositories and cubits
   - Trigger initial sync on app start

## Usage Example

### Initializing Services
```dart
// In main.dart or dependency injection
final connectivityService = ConnectivityService();
final sqliteRepo = SQLiteCardRepository();
final apiRepo = ApiCardRepository();
final syncService = SyncService(
  localRepo: sqliteRepo,
  apiRepo: apiRepo,
  connectivityService: connectivityService,
);
final hybridRepo = HybridCardRepository(
  localRepo: sqliteRepo,
  apiRepo: apiRepo,
  connectivityService: connectivityService,
  syncService: syncService,
);
```

### Using HybridRepository in Cubit
```dart
class CardCubit extends Cubit<CardState> {
  final HybridCardRepository _repository;
  final SyncService _syncService;
  StreamSubscription? _syncSubscription;

  CardCubit(this._repository, this._syncService) : super(CardInitial()) {
    _syncSubscription = _syncService.syncStatusStream.listen((status) {
      // Emit sync status to UI
      emit(state.copyWith(syncStatus: status));
    });
    
    // Trigger initial sync
    _syncService.syncAll(userId: currentUserId);
  }

  @override
  Future<void> close() {
    _syncSubscription?.cancel();
    return super.close();
  }
}
```

## Testing Scenarios

### Must Test
1. **Create card offline → Go online**
   - Verify card syncs to backend
   - Verify backendId is set

2. **Edit card offline → Go online**
   - Verify changes sync to backend
   - Verify needsSync becomes false

3. **Delete card offline → Go online**
   - Verify card deleted from backend

4. **Rapid online/offline transitions**
   - Verify no duplicate syncs
   - Verify data consistency

5. **Backend has newer data**
   - Verify local updates with backend data
   - Verify no local changes lost

6. **Multiple cards needing sync**
   - Verify all cards sync successfully
   - Verify partial failures don't block others

## Performance Considerations

- **Local-First**: All reads from SQLite for instant response
- **Async Sync**: Background sync doesn't block UI
- **Batch Operations**: Sync processes multiple cards efficiently
- **Error Handling**: Failed syncs retry on next connection
- **Status Updates**: UI receives real-time sync progress

## Security

- All API calls use JWT authentication
- Backend validates userId for all operations
- Local data encrypted by device
- No sensitive data in sync logs

## Future Enhancements

1. **Partial Sync**: Only sync changed fields
2. **Sync Intervals**: Periodic sync even when online
3. **Conflict UI**: Let user choose in conflicts
4. **Sync History**: Track sync events for debugging
5. **Bandwidth Optimization**: Compress sync payloads
