#include <stdio.h>
#include <stdlib.h>

#include "pd_api.h"

#include "sha256.h"

static PlaydateAPI* pd = NULL;
static int oxygen_sha256(lua_State* L);


#ifdef _WINDLL
__declspec(dllexport)
#endif

int
eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint32_t arg)
{
	if ( event == kEventInitLua )
	{
		pd = playdate;

		const char* err;

		if ( !pd->lua->addFunction(oxygen_sha256, "oxygen_sha256", &err) )
			pd->system->logToConsole("%s:%i: addFunction failed, %s", __FILE__, __LINE__, err);
	}

	return 0;
}

static int oxygen_sha256(lua_State* L)
{
	const char* input = pd->lua->getArgString(1);

	SHA256_CTX ctx;
	sha256_init(&ctx);
	sha256_update(&ctx, input, strlen(input));

	BYTE hash[SHA256_BLOCK_SIZE];
	sha256_final(&ctx, hash);

	char hex[2 * SHA256_BLOCK_SIZE + 1];
	for (size_t i = 0; i < SHA256_BLOCK_SIZE; i++) {
		// My C teacher would be proud.
		sprintf(hex + 2 * i, "%x%x", hash[i] >> 4, hash[i] & 0xF);
	}
	hex[2 * SHA256_BLOCK_SIZE] = '\0';

	pd->lua->pushString(hex);
	return 1;
}
