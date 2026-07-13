import { Head, Link, usePage } from '@inertiajs/react';
import { dashboard, login } from '@/routes';
/* @chisel-registration */
import { register } from '@/routes';
/* @end-chisel-registration */
import {
    BarChart3,
    BellRing,
    CalendarCheck2,
    FileSpreadsheet,
    QrCode,
    UtensilsCrossed,
} from 'lucide-react';

const features = [
    {
        icon: BarChart3,
        title: 'Live analytics',
        description:
            'Organiser dashboard with check-in, meal and session metrics that refresh automatically.',
    },
    {
        icon: UtensilsCrossed,
        title: 'Meal vouchers',
        description:
            'Scan QR vouchers at the serving line with a manual fallback and full redemption history.',
    },
    {
        icon: CalendarCheck2,
        title: 'Session attendance',
        description:
            'Track who attends each session and watch room capacity status in real time.',
    },
    {
        icon: BellRing,
        title: 'Push notifications',
        description:
            'Send announcements to attendees through Firebase Cloud Messaging, with a safe demo mode.',
    },
    {
        icon: QrCode,
        title: 'Offline-first scanning',
        description:
            'Scans made without a connection are queued on the device and replayed on reconnect.',
    },
    {
        icon: FileSpreadsheet,
        title: 'CSV reports',
        description:
            'Download attendance and redemption reports for the record straight from the app.',
    },
];

export default function Welcome() {
    const { auth } = usePage().props;

    return (
        <>
            <Head title="ConferenceCheck" />
            <div className="flex min-h-screen flex-col bg-[#F6F8F7] text-[#16302f] dark:bg-[#0b1514] dark:text-[#e6efee]">
                <header className="mx-auto flex w-full max-w-5xl items-center justify-between px-6 py-6">
                    <div className="flex items-center gap-2.5">
                        <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#23615F] text-white">
                            <QrCode className="h-5 w-5" />
                        </span>
                        <span className="text-lg font-bold tracking-tight">
                            ConferenceCheck
                        </span>
                    </div>
                    <nav className="flex items-center gap-3 text-sm">
                        {auth.user ? (
                            <Link
                                href={dashboard()}
                                className="rounded-lg bg-[#23615F] px-4 py-2 font-medium text-white transition hover:bg-[#1b4d4b]"
                            >
                                Dashboard
                            </Link>
                        ) : (
                            <>
                                <Link
                                    href={login()}
                                    className="rounded-lg px-4 py-2 font-medium text-[#23615F] transition hover:bg-[#23615F]/10 dark:text-[#8fc7c4]"
                                >
                                    Log in
                                </Link>
                                {/* @chisel-registration */}
                                <Link
                                    href={register()}
                                    className="rounded-lg bg-[#23615F] px-4 py-2 font-medium text-white transition hover:bg-[#1b4d4b]"
                                >
                                    Register
                                </Link>
                                {/* @end-chisel-registration */}
                            </>
                        )}
                    </nav>
                </header>

                <main className="mx-auto w-full max-w-5xl grow px-6 pb-16">
                    <section className="py-14 text-center lg:py-20">
                        <p className="mb-4 inline-block rounded-full border border-[#23615F]/20 bg-[#23615F]/10 px-4 py-1.5 text-xs font-semibold tracking-wide text-[#23615F] uppercase dark:border-[#8fc7c4]/25 dark:bg-[#8fc7c4]/10 dark:text-[#8fc7c4]">
                            Analytics · Meals · Notifications
                        </p>
                        <h1 className="mx-auto max-w-2xl text-4xl font-extrabold tracking-tight lg:text-5xl">
                            Run conference check-ins without the queues
                        </h1>
                        <p className="mx-auto mt-5 max-w-xl text-base leading-relaxed text-[#4b6361] dark:text-[#9db4b2]">
                            ConferenceCheck pairs this Laravel API with a
                            Flutter mobile app so organisers, scanners and
                            attendees can handle badges, meal vouchers, session
                            attendance and announcements from one place.
                        </p>
                        <div className="mt-8 flex items-center justify-center gap-3">
                            <Link
                                href={auth.user ? dashboard() : login()}
                                className="rounded-xl bg-[#23615F] px-6 py-3 text-sm font-semibold text-white shadow-lg shadow-[#23615F]/20 transition hover:bg-[#1b4d4b]"
                            >
                                {auth.user ? 'Open dashboard' : 'Log in to get started'}
                            </Link>
                        </div>
                    </section>

                    <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                        {features.map(({ icon: Icon, title, description }) => (
                            <div
                                key={title}
                                className="rounded-2xl border border-black/6 bg-white p-5 dark:border-white/10 dark:bg-[#12211f]"
                            >
                                <span className="mb-3 inline-flex h-9 w-9 items-center justify-center rounded-lg bg-[#23615F]/10 text-[#23615F] dark:bg-[#8fc7c4]/10 dark:text-[#8fc7c4]">
                                    <Icon className="h-4.5 w-4.5" />
                                </span>
                                <h2 className="mb-1 text-sm font-bold">
                                    {title}
                                </h2>
                                <p className="text-sm leading-relaxed text-[#4b6361] dark:text-[#9db4b2]">
                                    {description}
                                </p>
                            </div>
                        ))}
                    </section>
                </main>

                <footer className="border-t border-black/6 py-6 text-center text-xs text-[#4b6361] dark:border-white/10 dark:text-[#9db4b2]">
                    ConferenceCheck Mobile — Laravel API · Flutter app · UNZA
                    capstone project
                </footer>
            </div>
        </>
    );
}
