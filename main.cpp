#include <iostream>
#include <string_view>
#include <ranges>
#include <ios>
#include <dlfcn.h>

auto load_and_run(const int mode) -> int
{
    // Load the shared library
    void* lib_handle = dlopen(MYSODIR "/libmylib.so", mode);

    // Check if the library was loaded successfully
    if (!lib_handle)
    {
        fprintf(stderr, "Error loading library: %s\n", dlerror());
        return 1;
    }

    // Load the symbol (function) from the library
    using func_ptr = void(*)();
    const auto print = reinterpret_cast<func_ptr>(dlsym(lib_handle, "print"));

    // Check if the symbol was found
    if (!print)
    {
        fprintf(stderr, "Error loading symbol: %s\n", dlerror());
        dlclose(lib_handle);
        return 2;
    }

    // Call the function
    print();

    // Unload the library
    dlclose(lib_handle);
    return 0;
}

int main(const int argc, char* argv[])
{
    if (argc != 2) exit(EXIT_FAILURE);
    printf("\nSTATIC_APP: %s\n",STATIC_APP);

    int mode{};
    auto const updateMode = [&](const std::string_view flag)
    {
        using namespace std::string_view_literals;
#define flag_set(x) do { if (flag == (#x##sv)) {printf("%s\n",(#x)); mode |= (x); return; }} while(false)
        flag_set(RTLD_NOW);
        flag_set(RTLD_LAZY);
        flag_set(RTLD_GLOBAL);
        flag_set(RTLD_LOCAL);
        flag_set(RTLD_DEEPBIND);
#undef flag_set
    };

    auto input = std::string_view{argv[1]};
    auto flagStart = input.begin();
    auto const end = input.end();
    while (true)
    {
        const auto flagEnd = std::find(flagStart, end, '|');
        const auto flag = std::string_view(flagStart, flagEnd);
        updateMode(flag);
        if (flagEnd == end) break;
        flagStart = std::next(flagEnd);
    }

    if (const auto res = load_and_run(mode); res != 0)
    {
        std::cout << "err: " << res << "\n";
        exit(EXIT_FAILURE);
    }
    else
    {
        std::cout << "OK\n";
        exit(EXIT_SUCCESS);
    }
}
