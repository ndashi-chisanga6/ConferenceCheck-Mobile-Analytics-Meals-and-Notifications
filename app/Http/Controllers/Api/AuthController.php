<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Api\LoginRequest;
use App\Http\Requests\Api\RegisterRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends ApiController
{
    public function register(RegisterRequest $request)
    {
        $user = User::query()->create($request->validated());
        $token = $user->createToken('mobile-api')->plainTextToken;

        return $this->ok('Registration successful.', ['user' => $user, 'token' => $token], 201);
    }

    public function login(LoginRequest $request)
    {
        $user = User::query()->where('email', $request->string('email'))->first();

        if (! $user || ! Hash::check($request->string('password'), $user->password)) {
            return $this->fail('Invalid login credentials.', ['email' => ['The provided credentials are incorrect.']], 401);
        }

        return $this->ok('Login successful.', ['user' => $user, 'token' => $user->createToken('mobile-api')->plainTextToken]);
    }

    public function me(Request $request)
    {
        return $this->ok('Authenticated user.', $request->user());
    }

    public function logout(Request $request)
    {
        $request->user()?->currentAccessToken()?->delete();

        return $this->ok('Logged out successfully.');
    }
}
