#pragma once

#include "Event.h"
#include "Contexts.h"

namespace Adversity
{
	class Events
	{
	public:
		static void Load(std::string a_context, std::string a_pack, std::vector<Event>& a_events, ConditionParser::RefMap& a_refs);
		static Event* GetById(std::string a_id);
		static std::vector<Event*> GetByIds(std::vector<std::string> a_ids);
		static std::vector<Event*> GetInContext(std::string a_context);
		static std::vector<Event*> GetInPack(std::string a_pack);
		static std::vector<std::string> GetIds(std::vector<Event*> a_Events);
		static std::vector<Event*> Filter(std::function<bool(Event* a_Event)> a_check);
		static std::vector<Event*> Filter(std::vector<Event*> a_events, std::function<bool(Event* a_Event)> a_check);
		
		static void PersistAll();
		static void Save(SKSE::SerializationInterface* a_intfc);
		static void Load(SKSE::SerializationInterface* a_intfc);
		static void Revert();

		template <typename T>
		static T GetValue(const std::string& a_id, const std::string& a_key, T a_default, bool a_persist)
		{
			if (const auto& ev = GetById(a_id)) {
				const auto& id = ev->GetPackId() + "/" + ev->GetName();

				if (!a_persist) {
					return _runtime.count(id) ? _runtime[id].GetValue(a_key, a_default) : a_default; 
				}

				if (_persistent.count(id)) {
					const auto& data = _persistent[id];

					if (data.HasValue<T>(a_key)) {
						return data.GetValue(a_key, a_default);
					}
				}

				return ev->GetValue(a_key, a_default);
			}

			return a_default;
		}

		template <typename T>
		static bool SetValue(const std::string& a_id, const std::string& a_key, T a_default, bool a_persist)
		{
			if (const auto& ev = GetById(a_id)) {
				const auto& id = ev->GetPackId() + "/" + ev->GetName();

				if (a_persist) {
					_persistent[id].SetValue(a_key, a_default);
					_dirty[ev->GetContext()] = true;
				} else {
					_runtime[id].SetValue(a_key, a_default);
				}

				return true;
			}

			return false;
		}
	private:
		static inline std::unordered_map<std::string, Event> _events;

		static inline std::unordered_map<std::string, Meta> _persistent;
		static inline std::unordered_map<std::string, bool> _dirty;
		
		static inline std::unordered_map<std::string, Meta> _runtime;
		
		static inline std::unordered_map<std::string, std::vector<Event*>> _contexts;
		static inline std::unordered_map<std::string, std::vector<Event*>> _packs;
	};
}