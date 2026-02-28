package com.example.app_lock

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.util.Log

data class ProfileData(
    val id: Int,
    val name: String,
    val emoji: String,
    val hashedPin: String
)

class LockDatabase(private val context: Context) {

    companion object {
        private const val TAG = "LockDatabase"
        private const val DB_NAME = "app_lock.db"
    }

    private var database: SQLiteDatabase? = null

    fun open() {
        close()
        try {
            val dbPath = context.getDatabasePath(DB_NAME)
            if (dbPath.exists()) {
                database = SQLiteDatabase.openDatabase(
                    dbPath.path,
                    null,
                    SQLiteDatabase.OPEN_READONLY or SQLiteDatabase.NO_LOCALIZED_COLLATORS
                )
                Log.d(TAG, "Database opened: ${dbPath.path}")
            } else {
                Log.w(TAG, "Database file not found: ${dbPath.path}")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open database", e)
            database = null
        }
    }

    fun close() {
        try {
            database?.close()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to close database", e)
        }
        database = null
    }

    fun isPackageLocked(packageName: String): Boolean {
        val db = database ?: return false
        return try {
            val cursor = db.rawQuery(
                "SELECT 1 FROM locked_apps WHERE package_name = ? LIMIT 1",
                arrayOf(packageName)
            )
            val locked = cursor.moveToFirst()
            cursor.close()
            locked
        } catch (e: Exception) {
            Log.e(TAG, "isPackageLocked query failed", e)
            false
        }
    }

    fun getLockedProfiles(packageName: String): List<ProfileData> {
        val db = database ?: return emptyList()
        val profiles = mutableListOf<ProfileData>()
        try {
            val cursor = db.rawQuery(
                """SELECT p.id, p.name, p.emoji, p.hashed_pin
                   FROM locked_apps la
                   INNER JOIN profiles p ON p.id = la.profile_id
                   WHERE la.package_name = ?""",
                arrayOf(packageName)
            )
            while (cursor.moveToNext()) {
                profiles.add(
                    ProfileData(
                        id = cursor.getInt(0),
                        name = cursor.getString(1),
                        emoji = cursor.getString(2),
                        hashedPin = cursor.getString(3)
                    )
                )
            }
            cursor.close()
        } catch (e: Exception) {
            Log.e(TAG, "getLockedProfiles query failed", e)
        }
        return profiles
    }
}
