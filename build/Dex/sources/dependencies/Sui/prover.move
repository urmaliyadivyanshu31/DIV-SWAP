// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module sui::prover {
    use sui::object;

    #[allow(unused_const)]
    const OWNED: u64 = 1;
    #[allow(unused_const)]
    const SHARED: u64 = 2;
    #[allow(unused_const)]
    const IMMUTABLE: u64 = 3;

    spec {
        // "public" functions to be used in specs as an equivalent of core Prover's builtins

        /// Verifies if a given object is owned.
        fun owned<T: key>(obj: T): bool {
            let addr = object::id(obj).bytes;
            exists<object::Ownership>(addr) &&
            global<object::Ownership>(addr).status == OWNED
        }

        /// Verifies if a given object is owned by a specific address.
        fun owned_by<T: key>(obj: T, owner: address): bool {
            let addr = object::id(obj).bytes;
            exists<object::Ownership>(addr) &&
            global<object::Ownership>(addr).status == OWNED &&
            global<object::Ownership>(addr).owner == owner
        }

        /// Verifies if a given object is shared.
        fun shared<T: key>(obj: T): bool {
            let addr = object::id(obj).bytes;
            exists<object::Ownership>(addr) &&
            global<object::Ownership>(addr).status == SHARED
        }

        /// Verifies if a given object is immutable.
        fun immutable<T: key>(obj: T): bool {
            let addr = object::id(obj).bytes;
            exists<object::Ownership>(addr) &&
            global<object::Ownership>(addr).status == IMMUTABLE
        }

        /// Verifies if a given object has a field with a given name.
        fun has_field<T: key, K: copy + drop + store>(obj: T, name: K): bool {
            let uid = object::borrow_uid(obj);
            uid_has_field<K>(uid, name)
        }

        /// Returns the number of K-type fields of a given object.
        fun num_fields<T: key, K: copy + drop + store>(obj: T): u64 {
            let uid = object::borrow_uid(obj);
            uid_num_fields<K>(uid)
        }

        // "helper" functions - may also be used in specs but mostly opaque ones defining behavior of key
        // framework functions

        fun uid_has_field<K: copy + drop + store>(uid: sui::object::UID, name: K): bool {
            let addr = object::uid_to_address(uid);
            exists<object::DynamicFields<K>>(addr) && contains(global<object::DynamicFields<K>>(addr).names, name)
        }

        fun uid_num_fields<K: copy + drop + store>(uid: sui::object::UID): u64 {
            let addr = object::uid_to_address(uid);
            if (!exists<object::DynamicFields<K>>(addr)) {
                0
            } else {
                len(global<object::DynamicFields<K>>(addr).names)
            }
        }
    }

    // Remove an element at index from a vector and return the resulting vector (redirects to a
    // function in vector theory)
    native fun vec_remove<T>(v: vector<T>, elem_idx: u64): vector<T>;
}