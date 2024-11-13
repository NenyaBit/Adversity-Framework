#include "Contexts.h"
#include "Packs.h"
#include "Devices.h"
#include "Actors.h"
#include "Serialization.h"

using namespace Adversity;

namespace
{
	constexpr std::string_view dir = "Data/SKSE/AdversityFramework/Contexts";
}

void Contexts::Init()
{
	if (!fs::is_directory(dir)) {
		logger::error("no context directory exists");
		return;
	}

	logger::info("initialization contexts");

	const auto start = std::chrono::high_resolution_clock::now();

	for (const auto& a : fs::directory_iterator(dir)) {
		if (!fs::is_directory(a)) {
			continue;
		}

		const auto path{ a.path().string() };
		const auto id{ Util::Lower(a.path().filename().replace_extension().string()) };
		
		try {
			const auto t1 = std::chrono::high_resolution_clock::now();

			_dirty[id] = false;
			Load(id);

			Packs::Load(id);
			Devices::Load(id);
			Actors::Load(id);

			const auto t2 = std::chrono::high_resolution_clock::now();

			logger::info("loaded context {} in {}ms", id, std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count());

		} catch (const std::exception& e) {
			logger::error("failed to load context {}: {}", path, e.what());
		} catch (...) {
			logger::error("failed to load context {}", path);
		}
	}
	const auto end = std::chrono::high_resolution_clock::now();

	logger::info("finished initializing contexts in {}ms", std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count());
}

void Contexts::Reload()
{
	logger::info("reloading contexts");
	const auto start = std::chrono::high_resolution_clock::now();
	
	std::unique_lock lock{ _mutex };
	for (const auto& [id, _] : _dirty) {
		const auto t1 = std::chrono::high_resolution_clock::now();
		Load(id);
		Devices::Load(id);
		Actors::Load(id);
		Packs::Reload(id);
		const auto t2 = std::chrono::high_resolution_clock::now();
		logger::info("loaded context {} in {}ms", id, std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count());
	}
	
	const auto end = std::chrono::high_resolution_clock::now();
	logger::info("finished reloading contexts in {}ms", std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count());
}

void Contexts::Load(const std::string& a_id)
{
	const auto base{ std::format("Data/SKSE/AdversityFramework/Contexts/{}/Config/config.yaml", a_id) };
	try {
		if (fs::exists(base)) {
			logger::info("loading base data for {}", a_id);
			auto context = YAML::LoadFile(base).as<Meta>();
			_base[a_id] = context;
		}
	} catch (std::exception& e) {
		logger::error("failed to load {} base config {}", a_id, e.what());
	}

	const auto custom{ std::format("Data/SKSE/AdversityFramework/Contexts/{}/Config/config.custom.yaml", a_id) };
	try {
		if (fs::exists(custom)) {
			logger::info("loading custom data for {}", a_id);
			auto context = YAML::LoadFile(custom).as<Meta>();
			_user[a_id] = context;
		}
	} catch (std::exception& e) {
		logger::error("failed to load {} custom config {}", a_id, e.what());
	}
}

void Contexts::Persist(const std::string& a_id)
{
	if (!_user.count(a_id)) {
		return;
	}

	std::unique_lock lock{ _mutex };

	const auto& context = _user[a_id];

	YAML::Node node{ context };

	const auto file{ std::format("Data/SKSE/AdversityFramework/Contexts/{}/Config/config.custom.yaml", a_id) };

	logger::info("persisting context: {} {}", a_id, file);

	std::ofstream fout(file);
	fout << node;

	_dirty.erase(a_id);
}

void Contexts::PersistAll()
{
	for (const auto& [id, context] : _user) {
		if (_dirty[id]) {
			Persist(id);
		}
	}
}

void Contexts::Save(SKSE::SerializationInterface* a_intfc)
{
	Serialization::Write(a_intfc, _runtime.size());
	for (const auto& [id, context] : _runtime) {
		Serialization::Write(a_intfc, id);
		context.Serialize(a_intfc);
	}
}

void Contexts::Load(SKSE::SerializationInterface* a_intfc)
{
	auto i = Serialization::Read<std::size_t>(a_intfc);
	for (; i > 0; i--) {
		const auto& id = Serialization::Read<std::string>(a_intfc);
		Meta meta{ a_intfc };
		_runtime[id] = meta;
	}
}

void Contexts::Revert()
{
	std::unique_lock lock{ _mutex };
	_runtime.clear();
}