#pragma once

#include "Meta.h"

namespace Adversity
{
	class Contexts
	{
	public:
		static void Init();
		static void Persist(const std::string& a_id);
		static void PersistAll();
		static void Save(SKSE::SerializationInterface* a_intfc);
		static void Reload();
		static void Load(SKSE::SerializationInterface* a_intfc);
		static void Revert();

		template <typename T>
		static inline T GetValue(const std::string& a_id, const std::string& a_key, T a_default, bool a_persist)
		{
			std::unique_lock lock{ _mutex };
			const auto& id = Utility::CastLower(a_id);

			if (!a_persist) {
				const auto iter = _runtime.find(id);

				if (iter != _runtime.end()) {
					return iter->second.GetValue<T>(a_key, a_default);
				} else {
					return a_default;
				}
			}

			auto iter = _user.find(id);

			if (iter != _user.end()) {
				const auto& meta = iter->second;
				if (meta.HasValue<T>(a_key)) {
					return meta.GetValue<T>(a_key, a_default);
				}
			}

			iter = _base.find(id);
			if (iter != _base.end()) {
				const auto& meta = iter->second;
				if (meta.HasValue<T>(a_key)) {
					return meta.GetValue<T>(a_key, a_default);
				}
			}

			return a_default;
		}
		template <typename T>
		static inline bool SetValue(const std::string& a_id, const std::string& a_key, T a_val, bool a_persist)
		{
			std::unique_lock lock{ _mutex };
			const auto id = Utility::CastLower(a_id);

			if (!_dirty.count(id))
				return false;

			auto& map = a_persist ? _user : _runtime;
			map[id].SetValue<T>(a_key, a_val);

			_dirty[id] = true;

			return true;
		}
	private:
		static void Load(const std::string& a_id);
		
		static inline std::unordered_map<std::string, Meta> _runtime;
		static inline std::unordered_map<std::string, Meta> _base;
		static inline std::unordered_map<std::string, Meta> _user;

		static inline std::unordered_map<std::string, boolean> _dirty;
		static inline std::mutex _mutex;
	};
}