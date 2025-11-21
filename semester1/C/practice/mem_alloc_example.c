/*
 * ======================================================================================
 * PROJECT: In-Memory Student Ledger (Dynamic Memory Showcase)
 * ======================================================================================
 *
 * DESCRIPTION:
 * This program mimics a database engine that runs entirely in RAM.
 * It demonstrates advanced memory management patterns:
 * 1. Dynamic Structs: Each student is allocated individually on the Heap.
 * 2. Dynamic Strings: The 'name' field is a pointer, allocating only exactly what's needed.
 * 3. Dynamic Container: The array of pointers grows (reallocs) automatically as you add data.
 *
 * MEMORY HIERARCHY:
 * [ Database Struct ] -> [ Array of Pointers ] -> [ Student Struct ] -> [ Name String ]
 *
 * ======================================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// --- Data Structures ---

// The atomic unit of data
typedef struct {
    int id;
    char *name;     // Dynamic string (we don't know length at compile time)
    float gpa;
} Student;

// The container struct
typedef struct {
    Student **entries;  // A pointer to an array of Student pointers (Student* [])
    size_t count;       // Current number of elements
    size_t capacity;    // Total available slots before resizing needed
} Database;

// --- Function Prototypes ---

Database* db_create(size_t initial_capacity);
void db_insert(Database *db, int id, const char *name, float gpa);
void db_delete(Database *db, int id);
void db_print(const Database *db);
void db_free(Database *db);
void clear_input_buffer();

// --- Main Application Logic ---

int main() {
    // Initialize database with a small capacity to force reallocs explicitly
    // so we can see the logic work even with little data.
    Database *myDB = db_create(2); 
    
    int choice = 0;
    int tempId;
    float tempGpa;
    char nameBuffer[100]; // Temporary stack buffer for input

    printf("=== IN-MEMORY LEDGER SYSTEM ===\n");
    printf("Size initialized to 2 to demonstrate dynamic resizing.\n");

    while (1) {
        printf("\n--- MENU ---\n");
        printf("1. Add Student\n");
        printf("2. Delete Student (by ID)\n");
        printf("3. View All Records\n");
        printf("4. Show Memory Stats\n");
        printf("5. Exit\n");
        printf("Selection: ");
        
        if (scanf("%d", &choice) != 1) {
            printf("Invalid input. Try again.\n");
            clear_input_buffer();
            continue;
        }
        clear_input_buffer(); // Consume newline left by scanf

        switch (choice) {
            case 1:
                printf("Enter ID: ");
                scanf("%d", &tempId);
                clear_input_buffer();

                printf("Enter Name: ");
                // Securely read string
                if (fgets(nameBuffer, sizeof(nameBuffer), stdin) != NULL) {
                    // Remove trailing newline from fgets
                    nameBuffer[strcspn(nameBuffer, "\n")] = 0;
                }

                printf("Enter GPA: ");
                scanf("%f", &tempGpa);
                
                // Perform the insertion
                db_insert(myDB, tempId, nameBuffer, tempGpa);
                break;

            case 2:
                printf("Enter ID to delete: ");
                scanf("%d", &tempId);
                db_delete(myDB, tempId);
                break;

            case 3:
                db_print(myDB);
                break;

            case 4:
                printf("[DEBUG] Capacity: %zu | Count: %zu | Usage: %.2f%%\n", 
                       myDB->capacity, 
                       myDB->count, 
                       (float)myDB->count / myDB->capacity * 100.0);
                break;

            case 5:
                printf("Cleaning up memory and exiting...\n");
                db_free(myDB); // CRITICAL: Free all memory before exiting
                return 0;

            default:
                printf("Unknown option.\n");
        }
    }
}

// --- Implementation Details ---

/**
 * Creates the database container on the heap.
 * Uses calloc to ensure pointers are NULL initialized.
 */
Database* db_create(size_t initial_capacity) {
    Database *db = (Database*)malloc(sizeof(Database));
    if (!db) {
        fprintf(stderr, "Fatal: Failed to allocate database struct.\n");
        exit(1);
    }

    db->capacity = initial_capacity;
    db->count = 0;

    // Allocate the array of pointers. 
    // We use calloc so all pointers are initially NULL.
    db->entries = (Student**)calloc(initial_capacity, sizeof(Student*));
    if (!db->entries) {
        free(db);
        fprintf(stderr, "Fatal: Failed to allocate database entries.\n");
        exit(1);
    }

    return db;
}

/**
 * Inserts a record. Handles automatic resizing (REALLOC) if full.
 */
void db_insert(Database *db, int id, const char *name, float gpa) {
    // 1. Check if we need to expand memory
    if (db->count >= db->capacity) {
        size_t new_capacity = db->capacity * 2;
        printf("    >> [SYSTEM] Database full. Resizing from %zu to %zu slots...\n", db->capacity, new_capacity);

        // Realloc the ARRAY of pointers, not the students themselves.
        // The existing Student* pointers remain valid, they just move to a new array block.
        Student **new_entries = (Student**)realloc(db->entries, new_capacity * sizeof(Student*));
        
        if (!new_entries) {
            printf("Error: Out of memory! Cannot expand database.\n");
            return;
        }

        db->entries = new_entries;
        db->capacity = new_capacity;
    }

    // 2. Allocate memory for the STUDENT struct
    Student *new_student = (Student*)malloc(sizeof(Student));
    if (!new_student) return;

    new_student->id = id;
    new_student->gpa = gpa;

    // 3. Allocate memory for the NAME string
    // strdup acts like malloc(len + 1) then strcpy
    new_student->name = strdup(name); 
    if (!new_student->name) {
        free(new_student); // Rollback previous allocation
        return;
    }

    // 4. Store the pointer in our array
    db->entries[db->count] = new_student;
    db->count++;
    printf("    >> Record added successfully.\n");
}

/**
 * Removes a record by ID, shifts the array to fill the gap, 
 * and frees the specific memory associated with that record.
 */
void db_delete(Database *db, int id) {
    int found_index = -1;

    // Linear search for the ID
    for (size_t i = 0; i < db->count; i++) {
        if (db->entries[i]->id == id) {
            found_index = i;
            break;
        }
    }

    if (found_index == -1) {
        printf("    >> ID %d not found.\n", id);
        return;
    }

    Student *target = db->entries[found_index];

    // 1. Free the inner string (deep free)
    free(target->name);

    // 2. Free the struct wrapper
    free(target);

    // 3. Shift remaining pointers left to fill the gap
    // We start at the gap and pull the next item one slot back
    for (size_t i = found_index; i < db->count - 1; i++) {
        db->entries[i] = db->entries[i + 1];
    }

    // 4. Decrement count
    db->count--;
    
    // Nullify the last slot (now duplicate) to prevent dangling pointers
    db->entries[db->count] = NULL;

    printf("    >> Record %d deleted.\n", id);
}

/**
 * Prints the database in a formatted table.
 */
void db_print(const Database *db) {
    printf("\n--- CURRENT RECORDS (%zu/%zu) ---\n", db->count, db->capacity);
    if (db->count == 0) {
        printf("(Database is empty)\n");
        return;
    }

    printf("%-5s | %-20s | %-5s\n", "ID", "NAME", "GPA");
    printf("------------------------------------\n");
    for (size_t i = 0; i < db->count; i++) {
        Student *s = db->entries[i];
        printf("%-5d | %-20s | %-5.2f\n", s->id, s->name, s->gpa);
    }
    printf("------------------------------------\n");
}

/**
 * The "Destructor". Walks the entire structure freeing memory 
 * from the inside out.
 */
void db_free(Database *db) {
    if (!db) return;

    // 1. Loop through every student
    for (size_t i = 0; i < db->count; i++) {
        if (db->entries[i]) {
            // Free the name string inside the struct
            free(db->entries[i]->name);
            // Free the struct itself
            free(db->entries[i]);
        }
    }

    // 2. Free the array of pointers
    free(db->entries);

    // 3. Free the database container
    free(db);
    
    printf("    >> Memory cleanup complete. All blocks freed.\n");
}

// Utility to clear stdin buffer
void clear_input_buffer() {
    int c;
    while ((c = getchar()) != '\n' && c != EOF);
}
