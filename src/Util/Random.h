#pragma once

#include <random>

namespace Utility
{
	struct Random
	{
		Random() = delete;

		static inline std::mt19937 eng{ std::random_device{}() };

		template <class T>
		static inline T drawUniform(T a_min, T a_max)
		{
			if constexpr (std::is_integral_v<T>)
				return std::uniform_int_distribution<T>{ a_min, a_max }(eng);
			else
				return std::uniform_real_distribution<T>{ a_min, a_max }(eng);
		}

		// Draw a weighted-random index in [0, a_weights.size()-1]
		static inline int drawWeighted(std::vector<int> a_weights)
		{
			std::discrete_distribution<int> d{ a_weights.begin(), a_weights.end() };
			return d(eng);
		}

		template <class V>
		static inline void shuffle(V& a_container)
		{
			std::ranges::shuffle(a_container, eng);
		}

		static inline std::string GenerateUUID()
		{
			constexpr std::string_view v = "0123456789abcdef";
			constexpr std::string_view templateStr { "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" };
			std::uniform_int_distribution<size_t> dist{ 0, v.size() };

			std::string ret{ templateStr };
			for (int i = 0; i < ret.size(); i++) {
				if (ret[i] == 'x') {
					ret[i] = v[dist(eng)];
				}
			}
			return ret;
		}
	};
}	 // namespace Random
